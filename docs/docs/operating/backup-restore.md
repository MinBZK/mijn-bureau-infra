---
sidebar_position: 70
---

# Backup and restore

Data is the part of MijnBureau you cannot reinstall. This page covers the
strategy, the mechanism per datastore, and how to prove that a restore works.

Two layers are involved and they are not interchangeable:

1. **Datastore-native backups** understand the data. PostgreSQL archives WAL to
   object storage, giving point-in-time recovery.
2. **Velero** backs up Kubernetes objects and persistent volumes. It gives a
   consistent restore point for a whole namespace, but only at snapshot
   granularity.

A daily Velero snapshot means a 24-hour RPO. WAL archiving means minutes.

## What to protect

| Datastore                  | What it holds                                           | Can it be rebuilt? | Recommended protection                                                 |
| -------------------------- | ------------------------------------------------------- | ------------------ | ---------------------------------------------------------------------- |
| PostgreSQL (CloudNativePG) | Application data, users, permissions, DKIM keys         | No                 | Continuous WAL archiving plus scheduled base backups to object storage |
| SeaweedFS object store     | Uploaded files, documents, avatars, message attachments | No                 | Bucket copy or replication, or volume snapshots                        |
| Valkey                     | Caches, sessions, Celery queues                         | Mostly             | Volume snapshot, or treat as disposable                                |
| OpenSearch                 | Search index built from application data                | Yes                | Reindex; snapshots only for large indices                              |

User-generated content and identity data need tested backups. Derived data needs
a rebuild procedure.

## PostgreSQL

CloudNativePG (CNPG) writes base backups and WAL archives to an S3-compatible
bucket through `barman-cloud`. MijnBureau wires this for every bundled cluster.

Configuration lives in `helmfile/environments/default/backup.yaml.gotmpl`:

```yaml
backup:
  enabled: true
  cnpg:
    endpointURL: "https://s3.example.com" # S3-compatible endpoint
    bucket: "mijnbureau-backups"
    region: "eu-west-1"
    accessKey: "" # prefer a SOPS secrets file
    secretKey: ""
    pathPrefix: "postgresql"
    walCompression: "gzip"
    walEncryption: "AES256"
    dataCompression: "gzip"
    dataEncryption: "AES256"
    retentionPolicy: "30d"
    scheduledBackups:
      - name: daily-backup
        schedule: "0 0 0 * * *"
        backupOwnerReference: self
        method: barmanObjectStore
```

Each app's `helmfile/apps/<app>/values-cnpg-cluster.yaml.gotmpl` translates this
into a CNPG `backups:` block. Backups are only rendered when `backup.enabled` is
`true` **and** `backup.cnpg.endpointURL` is set, so leaving either empty keeps
the cluster running without archiving.

Every cluster writes to its own prefix, for example
`s3://mijnbureau-backups/postgresql/docs` and
`s3://mijnbureau-backups/postgresql/meet`.

Verify that archiving works before you rely on it:

```bash
kubectl get clusters -A
kubectl cnpg status <cluster> -n <namespace>
kubectl get backups.postgresql.cnpg.io -A
```

`kubectl cnpg status` reports the last archived WAL and any archiving failures;
a cluster that cannot archive WAL is not protected.

### Restore

Restoring a CNPG cluster means creating a new `Cluster` that bootstraps from the
object store:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: docs-cluster-restored
spec:
  instances: 1
  storage:
    size: 10Gi
  bootstrap:
    recovery:
      source: docs-backup
  externalClusters:
    - name: docs-backup
      barmanObjectStore:
        destinationPath: s3://mijnbureau-backups/postgresql/docs
        endpointURL: https://s3.example.com
        s3Credentials:
          accessKeyId:
            name: cnpg-backup-credentials
            key: ACCESS_KEY_ID
          secretAccessKey:
            name: cnpg-backup-credentials
            key: ACCESS_SECRET_KEY
```

Add `recoveryTarget.targetTime` to stop at a point in time instead of the latest
WAL. Restore into a new namespace and point the application at it, rather than
overwriting the running cluster.

Keep the encryption keys and bucket credentials outside the cluster: a backup
you cannot decrypt is not a backup.

## Object store (SeaweedFS)

The bundled SeaweedFS deployment keeps its volumes and filer metadata on PVCs.
There is no operator-managed backup, so choose one of:

- **Copy the buckets** to another S3-compatible store with `mc mirror` or
  `aws s3 sync`, scheduled as a CronJob. This is portable and does not depend on
  the storage layer.
- **Snapshot the PVCs** through your storage class and keep the snapshots off
  the same disk. This preserves the raw volume, but restoring requires a
  SeaweedFS-compatible setup.
- **Replicate** at the storage level if your Ceph or object-store backend
  supports it.

Back up bucket contents, not only the PVCs, when you need to restore a single
file. A volume snapshot restores everything or nothing.

## Valkey

Valkey persists to a PVC when `persistence.size` is set. Decide what an
acceptable loss is:

- Sessions and caches can normally be dropped; users log in again.
- Celery queues in Messages and Conversations can contain pending mail and
  background jobs. Losing them delays or drops work.

For a consistent snapshot, run `BGSAVE` and copy `dump.rdb` from the volume, or
snapshot the PVC. Valkey is not a system of record - document what you accept
losing instead of treating its PVC as a backup strategy.

## OpenSearch

OpenSearch holds a derived search index. The preferred recovery path is a
reindex from the source applications; take snapshots only when reindexing is too
slow or too expensive.

## Velero

Velero backs up Kubernetes resources and persistent volumes, and stores them in
an object storage bucket. Use it for namespace-level recovery, for a consistent
restore point before an upgrade, and to keep the archives off the cluster.

### Prerequisites

- CSI snapshot support, or a Restic/node-agent setup for file-system backups.
- An object storage bucket for backup archives.
- Credentials with write, read, list and delete permissions.
- A retention policy that matches your compliance requirements.
- The Velero CLI on your workstation (`brew install velero`).

### Install

```bash
velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.11.0 \
  --bucket <backup-bucket> \
  --secret-file ./credentials-velero \
  --backup-location-config region=<region>,s3ForcePathStyle=true,s3Url=<s3-endpoint> \
  --snapshot-location-config region=<region>
```

If your cluster does not support CSI snapshots for every volume, add
`--use-node-agent` for file-system backups. Confirm health:

```bash
kubectl -n velero get pods
velero backup-location get
```

### Schedules

```bash
velero schedule create mijnbureau-daily \
  --schedule "0 2 * * *" \
  --ttl 720h \
  --include-namespaces keycloak,nextcloud

velero schedule create mijnbureau-critical \
  --schedule "0 */6 * * *" \
  --ttl 168h \
  --include-namespaces keycloak,nextcloud
```

Run an ad-hoc backup before risky operations:

```bash
velero backup create pre-upgrade-$(date +%Y%m%d-%H%M) \
  --include-namespaces keycloak,nextcloud \
  --wait

velero backup describe <backup-name> --details
velero backup logs <backup-name>
```

### Restore

```bash
velero restore create --from-backup <backup-name>
velero restore get
velero restore describe <restore-name> --details
```

Restore into a temporary namespace first when you want to validate the data
without interrupting users, then re-enable traffic.

### Retention

A tiered policy balances cost and recovery needs:

- every 6 hours: keep 7 days
- daily: keep 30 days
- weekly: keep 12 weeks
- monthly: keep 12 months

Adjust it to your legal and organisational requirements.

## Checklist

1. Set `backup.enabled: true` and configure `backup.cnpg.*` with credentials from
   a SOPS secrets file, not plain values.
2. Confirm that `kubectl cnpg status` reports successful WAL archiving for every
   cluster.
3. Schedule bucket copies for the object store.
4. Decide and document the RPO/RTO for Valkey and OpenSearch.
5. Run a restore drill into a scratch namespace at least quarterly, and record
   how long it took.
6. Alert on backup age: a backup job that silently stops is worse than none,
   because it looks like protection.
7. Store backups in a separate account or project, ideally in an immutable
   bucket, and keep encryption keys and credentials apart from the backups.
8. Keep backup and restore logs as audit evidence.
