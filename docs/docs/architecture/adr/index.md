---
sidebar_position: 10
---

# Architecture Decision Records

An ADR records a decision, the alternatives that were considered and the
consequences, so a future reader does not have to reverse-engineer the intent.

**Status of every ADR in this list:** accepted unless the ADR itself says
otherwise. An ADR is not changed after acceptance; a new ADR supersedes it and
both stay in the repository.

## Platform and runtime

| ADR                           | Decision                              |
| ----------------------------- | ------------------------------------- |
| [ADR-MB-002](./adr-mb-002.md) | Kubernetes as the deployment platform |
| [ADR-MB-003](./adr-mb-003.md) | System provisioning                   |
| [ADR-MB-006](./adr-mb-006.md) | Datastores                            |
| [ADR-MB-015](./adr-mb-015.md) | PostgreSQL through CloudNativePG      |
| [ADR-MB-021](./adr-mb-021.md) | Environment model                     |
| [ADR-MB-027](./adr-mb-027.md) | SeaweedFS as the bundled object store |

## Architecture and integration

| ADR                           | Decision                                  |
| ----------------------------- | ----------------------------------------- |
| [ADR-MB-001](./adr-mb-001.md) | Use ADRs to define architecture decisions |
| [ADR-MB-008](./adr-mb-008.md) | Helm chart standard                       |
| [ADR-MB-009](./adr-mb-009.md) | Resource labels                           |
| [ADR-MB-010](./adr-mb-010.md) | Ingress controller                        |
| [ADR-MB-012](./adr-mb-012.md) | Align with partner tools                  |
| [ADR-MB-014](./adr-mb-014.md) | Routing model                             |
| [ADR-MB-018](./adr-mb-018.md) | Identity and tenancy model                |
| [ADR-MB-020](./adr-mb-020.md) | AI provider architecture                  |
| [ADR-MB-026](./adr-mb-026.md) | Component selection exceptions            |

## Security and supply chain

| ADR                           | Decision                               |
| ----------------------------- | -------------------------------------- |
| [ADR-MB-011](./adr-mb-011.md) | Container image sources                |
| [ADR-MB-016](./adr-mb-016.md) | Secrets derived from a master password |
| [ADR-MB-017](./adr-mb-017.md) | Default-deny network isolation         |
| [ADR-MB-019](./adr-mb-019.md) | Container supply chain                 |

## Delivery and operations

| ADR                           | Decision                          |
| ----------------------------- | --------------------------------- |
| [ADR-MB-004](./adr-mb-004.md) | Gitmoji commits                   |
| [ADR-MB-005](./adr-mb-005.md) | GitHub for source code management |
| [ADR-MB-007](./adr-mb-007.md) | Manifest tests                    |
| [ADR-MB-013](./adr-mb-013.md) | Load-testing tool                 |
| [ADR-MB-022](./adr-mb-022.md) | Backup and disaster recovery      |
| [ADR-MB-023](./adr-mb-023.md) | Air-gapped delivery               |
| [ADR-MB-024](./adr-mb-024.md) | Observability dashboards          |
| [ADR-MB-025](./adr-mb-025.md) | Testing strategy                  |
