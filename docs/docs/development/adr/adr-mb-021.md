# ADR-MB-021: Environment model

## Status

Accepted

## Context

The repository ships three environments: `default`, `demo` and `production`. Without an
explicit contract, it is unclear which services MijnBureau provides, which choices a user
must make, and why a release behaves differently between environments. The difference is
not cosmetic: PostgreSQL, cache and object storage releases are only deployed in `demo`,
so the same values render different manifests per environment.

## Decision

We will keep three environments with the following contract.

- **`default`** — reference configuration without bundled datastores. It is not recommended
  for production because it has no environment-specific customisation.
- **`demo`** — a complete, self-contained installation for evaluation and testing. It
  deploys CloudNativePG clusters, Valkey and MinIO, seeds a realm with an organization and
  demo users, and enables features that production leaves to the operator.
- **`production`** — external datastores and identity decisions supplied by the operator.
  No database, cache or object store release is installed.

Environment gating is explicit in the charts (`eq .Environment.Name "demo"`), not implicit in
values inheritance. Release-specific behaviour must be covered by the test matrix in
`tests/*.yaml` and rendered in CI for every environment.

## Consequences

**Pros:**

- ✅ Users know what they get from each environment without reading charts.
- ✅ Demo remains a one-command installation with real dependencies.
- ✅ Production never installs stateful services the operator does not want.

**Cons:**

- ❌ Every chart change must be validated against three environments.
- ❌ Demo-only behaviour can hide bugs that appear only with external datastores.
- ❌ The `default` environment invites use as a production baseline even though it is not
  supported as one.
