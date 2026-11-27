# seaweedfs (object store)

MijnBureau's in-house S3-compatible object store chart. It runs SeaweedFS
(`weed server`: master + volume + filer + S3 gateway) in a single StatefulSet
pod. It replaces the vendored Bitnami MinIO chart.

## Why an in-house chart

The upstream SeaweedFS chart cannot satisfy the repository policies without
patches:

- `hostPath` data volumes by default, `emptyDir` in all-in-one mode
- no `app.kubernetes.io/version` label on resources and pod templates
- random S3 credentials generated with `lookup`, which makes `helmfile template`
  non-deterministic
- an all-in-one Service that exposes the unauthenticated master, volume and
  filer APIs

Everything above is designed correctly here instead of patched at the values
layer.

## Design notes

- **One instance per application**, in the application namespace, keeping the
  existing per-app isolation.
- **Resources are named `<app>-seaweedfs`** (StatefulSet, Service, Secret) and
  `<app>-seaweedfs-data` (PVC). Public hostnames stay user-facing and use
  `<app>-objectstore.<domain>`.
- **Only the S3 port is exposed** on the ClusterIP Service. Master and filer are
  reachable only through the headless Service, and the NetworkPolicy allows
  those ports from the bucket setup Job only.
- **Credentials** come from `.Values.auth` (chart-managed Secret) or from
  `.Values.auth.existingSecret` (External Secrets). The S3 gateway config file
  is rendered at container start from the Secret keys, so both paths behave
  identically.
- **`server.externalUrl`** must be the public URL when the store is reachable
  through a Gateway or Ingress. SeaweedFS uses it for presigned URLs and for
  SigV4 verification behind a reverse proxy.
- **Buckets** are created by a post-install/post-upgrade Job. `weed shell` is
  not idempotent for `s3.bucket.create`, so the Job checks `s3.bucket.list`
  first.

## Values

The values block for the server is `server`. Every release also receives the
environment-wide `.Values.objectstore.<app>` map (the endpoint and credentials
the _application_ uses), which is named after the user-facing concept rather
than the implementation.

See `values.yaml` for the full list.
