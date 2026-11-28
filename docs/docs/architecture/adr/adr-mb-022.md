# ADR-MB-022: Backup and disaster recovery

## Status

Proposed

## Context

MijnBureau stores documents, mail, chat history, calendars and identity data. Losing any of
those is operationally unacceptable, yet the demo environment intentionally ships without
backups. There is no written statement of what is backed up, how often, or what recovery
guarantees a service integrator must provide.

Backups span three kinds of data: Kubernetes resources, persistent volumes and databases.
CloudNativePG provides its own backup and point-in-time recovery mechanisms, which do not
run through Velero.

## Decision

We will standardise on Velero for namespace and persistent-volume backups, combined with
CloudNativePG backups for PostgreSQL.

- Velero backs up application namespaces, persistent volumes and the cluster-scoped
  resources required to restore them.
- PostgreSQL clusters use CNPG `ScheduledBackup` to object storage, enabling point-in-time
  recovery.
- Object storage buckets are backed up at the storage layer or replicated; Velero does not
  copy object contents.
- The demo environment is explicitly out of scope and documents that it has no backups.
- Service integrators define RPO and RTO; MijnBureau documents the mechanism, not a
  guarantee.

## Consequences

**Pros:**

- ✅ One documented mechanism instead of per-application ad-hoc dumps.
- ✅ Database recovery uses PostgreSQL-native WAL archiving rather than file copies.
- ✅ The out-of-scope demo behaviour is explicit instead of implied.

**Cons:**

- ❌ Requires object storage for both Velero and CNPG backups.
- ❌ Restores must be tested per application; resource ordering matters.
- ❌ Encryption keys and the master password must be recoverable independently of the
  backup.
- ❌ Velero is not deployed by MijnBureau; operators must install it.
