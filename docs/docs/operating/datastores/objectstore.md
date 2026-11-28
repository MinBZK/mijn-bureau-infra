---
sidebar_position: 40
---

# Object Stores

Object stores are designed to store and retrieve large amounts of unstructured data, such as files, images, and backups. They are highly scalable and offer features like versioning, replication, and lifecycle management.

## Managed vs. Self-Hosted Object Stores

- **Managed Services**: Cloud providers offer fully managed object storage solutions. These services handle infrastructure, scaling, and maintenance.
- **Self-Hosted Solutions**: Tools like Garage or SeaweedFS allow you to deploy and manage your own object store, providing greater control and data sovereignty.

## SeaweedFS in Kubernetes

MijnBureau ships its own `objectstore` Helm chart
(`helmfile/apps/common/charts/seaweedfs`) that runs
[SeaweedFS](https://github.com/seaweedfs/seaweedfs) as a single StatefulSet pod:
master, volume server, filer and the S3 gateway in one process (`weed server`).

The chart renders:

- a StatefulSet with a `ReadWriteOnce` PVC for `/data`;
- a ClusterIP Service that exposes **only** the S3 API (port `8333`);
- a headless Service for the internal master and filer endpoints;
- a NetworkPolicy that only allows same-namespace pods to reach the S3 API;
- an optional Ingress or HTTPRoute for public access;
- a post-install Job that creates the configured buckets.

In the demo environment one object store runs per application, in the
application namespace, and is released as `<app>-seaweedfs` (public hostnames use
`<app>-objectstore.<domain>`).

## Integrating the Object Store with MijnBureau

The defaults for every application live in
`helmfile/environments/default/objectstore.yaml.gotmpl`.

### Example: Configuring the Object Store for MijnBureau

To point an application at an object store, add the following to
`helmfile/environments/production/mijnbureau.yaml.gotmpl`:

```yaml
objectstore:
  nextcloud:
    bucket: "nextcloud"
    accessKey: "admin"
    endpoint: "yourhostname"
    port: 8333
    useSSL: true
    isInternal: false
    secretKey: yourpassword
```

`endpoint` is the host of the S3 API. Use the in-cluster Service name
(`<app>-seaweedfs`) for internal access, or the public hostname when the
object store is exposed through a Gateway/Ingress. Whenever the store is
reachable through a reverse proxy, set the chart's `server.externalUrl` to the
same public URL so presigned URLs and SigV4 verification work.

### Securing Object Store Credentials

Storing credentials directly in configuration files is not recommended. Use a
secrets file to manage credentials securely. Loading a secrets file is disabled
by default; enable the `secrets:` block in
`helmfile/bases/environment.yaml.gotmpl` as described in
[Secrets](../secrets/sops.md).

1. Add the credentials to a secrets file:

   ```yaml
   objectstore:
     nextcloud:
       accessKey: "admin"
       secretKey: yourpassword
   ```

   Save this in `helmfile/environments/production/secrets.yaml`.

2. Remove the `accessKey` and `secretKey` fields from
   `mijnbureau.yaml.gotmpl`.

3. Encrypt the secrets file using SOPS:

   ```bash
   sops -e -i helmfile/environments/production/secrets.yaml
   ```

4. Ensure your CI/CD system is configured to decrypt the secrets during deployment.

With `secrets.backend: external` the credentials are stored in OpenBao under
`secret/data/mijnbureau/<env>/seaweedfs` and synced into a
`<app>-seaweedfs` Secret by the External Secrets Operator. The chart reads
the `access-key` and `secret-key` keys from that Secret.

## Backups

The object store holds uploaded files, which are not rebuildable. Copy the
buckets to another S3-compatible store or snapshot the volumes. See
[Backups](../backup-restore.md#object-store-seaweedfs) for the options and why a bucket
copy is usually preferable to a volume snapshot.
