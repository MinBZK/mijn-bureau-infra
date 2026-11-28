# ADR-MB-015: PostgreSQL through CloudNativePG

## Status

Accepted (amends ADR-MB-006)

## Context

ADR-MB-006 states that MijnBureau provides datastores for the demo environment only.
It does not say how the PostgreSQL databases are provisioned. Originally each application
chart carried its own database deployment or relied on a shared chart. That produced
divergent backup, failover and upgrade behaviour.

Every application in the suite needs a PostgreSQL database with the same operational
properties: TLS, credentials rotation, backups and a predictable failover model.
[CloudNativePG](https://cloudnative-pg.io/) provides these as Kubernetes primitives
(`Cluster`, `Backup`, `ScheduledBackup`, `Pooler`).

## Decision

We will use CloudNativePG as the only PostgreSQL provisioning mechanism.

- In the demo environment, MijnBureau deploys one `Cluster` per application through the
  shared `common/charts/cluster` chart; there is no other database provider toggle.
- In production, operators either install CloudNativePG and let MijnBureau create the
  clusters, or point `database.<app>.*` at an external PostgreSQL service. The
  applications require PostgreSQL 16 or newer.
- The CloudNativePG operator and its CRDs must be installed before `helmfile apply`.

## Consequences

**Pros:**

- ✅ One database model across all applications: credentials, TLS, failover and monitoring
  behave identically.
- ✅ Backups and point-in-time recovery use native CNPG resources instead of ad-hoc dumps.
- ✅ The operator reconciles upgrades and failover, which removes per-chart database logic.

**Cons:**

- ❌ A cluster-wide operator and CRDs are a prerequisite; a plain `helmfile apply` on a
  cluster without CNPG fails.
- ❌ Users must size storage per application (`pvc.<app>.storageClass`).
- ❌ Applications remain coupled to PostgreSQL; databases such as SQLite are not supported.
