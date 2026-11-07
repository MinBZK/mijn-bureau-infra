# Local patches

Vendored from `valkey-io/valkey-helm` chart `valkey-0.12.1` (appVersion `9.1.3`).

Local changes:

- Added `metadata.namespace: {{ .Release.Namespace }}` to top-level resources so the
  repository's namespace policy can validate rendered manifests.
- Removed the upstream `templates/tests/` Helm test hooks so the repository's policy
  checks do not treat test Pods as runtime workloads.

No runtime behavior of the Valkey deployment was changed.
