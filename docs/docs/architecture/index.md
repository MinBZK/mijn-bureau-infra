---
sidebar_position: 10
---

# Architecture

This section explains why MijnBureau is built the way it is. It is aimed at
architects and reviewers who need to understand the constraints behind a
configuration choice before changing it.

## Decisions

Architecture decisions are recorded as ADRs in
[Architecture Decision Records](./adr/index.md). Each ADR states the context, the
decision and the consequences; when a page and an ADR disagree, the ADR is the
intent and the page is the instruction.

## Solution architecture

The [solution architecture](./solution-architectuur/index.md) describes MijnBureau
as a whole, in Dutch: the business goals and principles, the information
architecture, and the technical architecture.

| Part                                                                           | Covers                                                   |
| ------------------------------------------------------------------------------ | -------------------------------------------------------- |
| [Solution architecture](./solution-architectuur/index.md)                      | Goals, scope, approach and reading guide                 |
| [Business architecture](./solution-architectuur/business-architectuur.md)      | Business goals, principles, requirements and laws        |
| [Information architecture](./solution-architectuur/informatie-architectuur.md) | Data, standards, authentication and the functional model |
| [Technical architecture](./solution-architectuur/technische-architectuur.md)   | Components, deployment, operations and security          |

## The short version

- **Kubernetes is the only deployment target.** Every component ships as a Helm
  chart, rendered by Helmfile. Nothing is installed by hand on a node.
- **One Helmfile, three environments.** `default` holds the shared values,
  `demo` adds bundled datastores, `production` expects external services.
- **Secrets are derived or synced.** Derived secrets from
  `MIJNBUREAU_MASTER_PASSWORD` are the baseline; SOPS files override individual
  values; external secret managers can take over entirely.
- **Default deny networking.** Namespaces only reach what a NetworkPolicy lets
  them reach, including cluster DNS and the identity provider.
- **Everything is versioned.** Image versions are updated by updatecli, releases
  publish digests, SBOMs and signature status, and CI validates the rendered
  manifests before merge.

## Common questions

| Question                                                    | Where the answer lives            |
| ----------------------------------------------------------- | --------------------------------- |
| Why CloudNativePG instead of the upstream PostgreSQL chart? | [ADR-MB-015](./adr/adr-mb-015.md) |
| Why derive secrets from one master password?                | [ADR-MB-016](./adr/adr-mb-016.md) |
| Why is everything denied by default on the network?         | [ADR-MB-017](./adr/adr-mb-017.md) |
| How are environments modelled?                              | [ADR-MB-021](./adr/adr-mb-021.md) |
| Why is SeaweedFS the bundled object store?                  | [ADR-MB-027](./adr/adr-mb-027.md) |
| Why digest/signature checks on images?                      | [ADR-MB-019](./adr/adr-mb-019.md) |
