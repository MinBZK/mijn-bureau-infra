---
sidebar_position: 14
---

# Backups

This page explains how you run backups for MijnBureau with Velero.

Velero backs up Kubernetes resources and persistent volumes. You can use it to recover from accidental deletion, cluster failures, and failed upgrades.

## Backup Scope

Use Velero to back up these parts of your platform:

- Namespace resources for MijnBureau applications.
- Persistent volumes for stateful workloads.
- Cluster-scoped resources that are required to restore applications correctly.

Typical stateful components include:

- Keycloak
- Nextcloud
- OpenProject
- Grist
- Databases and object stores used by platform applications

## Prerequisites

Before you configure backups, make sure you have:

- A Kubernetes cluster with CSI snapshot support or a Restic/node-agent setup.
- An object storage bucket for backup archives.
- Credentials for object storage with write, read, list, and delete permissions.
- A retention policy that matches your compliance requirements.
- Velero CLI installed on your workstation.

## Install Velero CLI

Install the CLI with Homebrew:

```bash
brew install velero
```

Validate installation:

```bash
velero version
```

## Install Velero In The Cluster

Install Velero in the cluster and connect it to your backup bucket. The exact values depend on your cloud or on-prem storage provider.

Example installation flow:

```bash
velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.11.0 \
  --bucket <backup-bucket> \
  --secret-file ./credentials-velero \
  --backup-location-config region=<region>,s3ForcePathStyle=true,s3Url=<s3-endpoint> \
  --snapshot-location-config region=<region>
```

If your cluster does not support CSI snapshots for all volumes, enable file-system backups:

```bash
velero install --use-node-agent
```

After installation, confirm Velero is healthy:

```bash
kubectl -n velero get pods
velero backup-location get
```

## Create Scheduled Backups

Create separate schedules for high-frequency and low-frequency backups.

Example daily schedule:

```bash
velero schedule create mijnbureau-daily \
  --schedule "0 2 * * *" \
  --ttl 720h \
  --include-namespaces keycloak,nextcloud,openproject,grist
```

Example six-hour schedule for critical namespaces:

```bash
velero schedule create mijnbureau-critical \
  --schedule "0 */6 * * *" \
  --ttl 168h \
  --include-namespaces keycloak,nextcloud
```

List schedules:

```bash
velero schedule get
```

## Run Ad-Hoc Backups

Run an immediate backup before risky operations such as chart upgrades:

```bash
velero backup create pre-upgrade-$(date +%Y%m%d-%H%M) \
  --include-namespaces keycloak,nextcloud,openproject,grist \
  --wait
```

Inspect results:

```bash
velero backup describe <backup-name> --details
velero backup logs <backup-name>
```

## Restore Procedure

Use this restore flow when you recover an application namespace.

1. Identify the backup to restore.
2. Restore into the original namespace or a temporary namespace for validation.
3. Verify workload health, data integrity, and ingress routing.
4. Re-enable traffic when validation succeeds.

Example restore command:

```bash
velero restore create --from-backup <backup-name>
```

Track restore status:

```bash
velero restore get
velero restore describe <restore-name> --details
```

## Operational Recommendations

- Test restore procedures on a fixed cadence, at least monthly.
- Keep backup and restore logs for audit evidence.
- Store backups in a separate account or project to reduce blast radius.
- Use immutable bucket settings when your storage platform supports it.
- Encrypt data at rest and in transit.
- Monitor failed backups with alerting in your observability stack.

## Suggested Retention Policy

Use a tiered policy that balances cost and recovery needs:

- Every 6 hours: keep 7 days.
- Daily: keep 30 days.
- Weekly: keep 12 weeks.
- Monthly: keep 12 months.

Adjust retention to your legal and organizational requirements.

## Disaster Recovery Drill Checklist

Use this checklist for routine recovery drills:

1. Create a recent backup and record the backup identifier.
2. Restore one critical application in an isolated namespace.
3. Validate authentication, data access, and core user workflows.
4. Record recovery time objective and recovery point objective results.
5. Update procedures when validation finds gaps.
