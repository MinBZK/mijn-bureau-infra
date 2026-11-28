# ADR-MB-027: SeaweedFS as the bundled object store

## Status

Accepted (replaces the vendored Bitnami MinIO chart)

## Context

The demo environment ships one object store per application: twelve buckets spread over
nine releases (`nextcloud`, `docs`, `drive`, `meet`, `projects`, `people`, `dictaphone`,
`conversations`, `messages`). Until now these ran the vendored Bitnami MinIO chart
(`helmfile/apps/common/charts/minio`, 17.0.11).

MinIO changed its licence and distribution model: the upstream community images and the
`minio` binary are no longer published under terms that fit this repository, and the
Bitnami images we relied on moved to `bitnamilegacy` without a supported upgrade path.
Continuing on that chart would leave the demo environment on an unmaintained, licence-wise
unclear dependency.

The vendored chart also fought the repository policies: it needed per-app value files of
~1 800 lines to satisfy the label, security-context, `imagePullPolicy`, ServiceAccount and
NetworkPolicy rules, and its `provisioning` Job and console deployments added moving parts
(object browser, `os-shell` init container) that the suite never used.

## Decision

We will replace MinIO with SeaweedFS and manage the chart ourselves.

- **One SeaweedFS instance per application**, in the application namespace, released as
  `<app>-seaweedfs`. Public hostnames stay user-facing and use
  `<app>-objectstore.<domain>`. Per-app isolation is preserved: credentials, buckets and PVCs stay
  scoped to one application.
- **An in-house chart** at `helmfile/apps/common/charts/seaweedfs`, based on the
  `template/` scaffold and the shared `common` library. It runs `weed server`
  (master + volume + filer + S3 gateway) as a single-replica StatefulSet.
- **S3-compatible on port 8333.** The public Service exposes only the S3 API; master and
  filer are reachable through a headless Service and the NetworkPolicy limits them to the
  bucket setup Job.
- **The S3 gateway config is rendered at container start** from the `access-key` and
  `secret-key` Secret keys, so chart-managed Secrets and External Secrets Operator behave
  identically.
- **`server.externalUrl` is mandatory** whenever the store is reachable through the
  Gateway, so presigned URLs and SigV4 verification work behind the reverse proxy.
- **Buckets are created by a post-install/post-upgrade Job** that checks `s3.bucket.list`
  before calling `s3.bucket.create`, because `weed shell` is not idempotent for bucket
  creation.
- **Credential derivation moves from the `minio` salt to `seaweedfs`**, and the OpenBao
  path from `<env>/minio` to `<env>/seaweedfs`. Existing credentials and presigned URLs are
  invalid after the cutover; no data migration is performed because the demo environment
  has no data of record.

## Consequences

- The demo environment depends on `chrislusf/seaweedfs` (Apache-2.0). The image tag is
  pinned in `container.yaml.gotmpl` and bumped by `updatecli/updatecli.d/seaweedfs.yaml`.
- `appVersion` in the chart is `4.55.0` while the image tag is `4.55`, because
  `policy/labels.rego` requires the `app.kubernetes.io/version` label to be semver.
- There is one object store pod per application. A pod restart is downtime for that
  application's uploads; the PVC is `ReadWriteOnce` and there is no replication. This is
  acceptable for the demo environment and documented as a production follow-up.
- SeaweedFS keeps no console, so the per-app object browser is gone. It was never exposed:
  the MinIO console ingress was always disabled.
- Bucket lifecycle rules other than the `fs.configure -ttl` used for Messages imports are
  not managed by the chart. Setting S3 lifecycle configuration requires a follow-up Job.
- S3 client compatibility (checksum/chunked upload handling, presigned URL host
  verification, CORS preflight) must be verified per application; see the validation list
  in the migration issue.
