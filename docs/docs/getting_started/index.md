---
sidebar_position: 10
---

# Getting started

MijnBureau runs on Kubernetes and is installed with Helmfile. You can start on a
single machine and grow from there; the same charts and values work on a managed
cluster.

## Start here

1. [Prerequisites](./prerequisites.md) - tools, cluster access and the
   cluster-wide components MijnBureau expects.
2. [Installation](./installation.md) - obtain the software, choose an
   environment, configure and deploy.
3. [Example configuration](./example-config.md) - domains, namespaces,
   resources and Gateway settings.
4. [Single VPS with K3s](./single-vps-k3s.md) - a complete small deployment in one
   guide.

## What to decide before you install

MijnBureau makes default choices, but a few decisions change the architecture:

- **Identity provider**: run the bundled Keycloak, or connect an existing one.
  See [Identity federation](../security/identity-federation.md).
- **AI language models**: deploy Ollama locally, or point at an existing
  endpoint. Without it, AI features stay disabled.
- **Transactional email**: connect an SMTP relay for Messages notifications, or
  leave email sending off.
- **Video conferencing**: use the bundled LiveKit, or connect to an external
  provider.
- **Datastores**: the demo environment bundles PostgreSQL, Valkey and SeaweedFS;
  production expects external services. See
  [Datastores](../operating/datastores/index.md).

## Which environment do I need?

| Environment  | Use it for                                            | Datastores                 |
| ------------ | ----------------------------------------------------- | -------------------------- |
| `demo`       | Evaluation, development, a single VPS                 | Bundled in the cluster     |
| `production` | Real deployments                                      | External, you provide them |
| `default`    | The shared base; only use it directly if you know why | External                   |

Do not point a production deployment at the default environment just because it
starts faster; it is not tuned for it.

## After installation

- [Administration](../operating/administration.md) - admin portals, passwords and
  break-glass access.
- [Backup and restore](../operating/backup-restore.md) - protect the data before
  users depend on it.
- [Upgrades and rollback](../operating/upgrades.md) - how to move to a newer
  release safely.
