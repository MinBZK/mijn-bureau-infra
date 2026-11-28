---
sidebar_position: 10
---

# Operating MijnBureau

This section is for the people who run a deployment after it is installed:
access and administration, secrets, datastores, backups, DNS, upgrades and
monitoring.

## Start here

| Task                                                      | Page                                                 |
| --------------------------------------------------------- | ---------------------------------------------------- |
| Give someone admin access, or recover a lost password     | [Administration](./administration.md)                |
| Administer Keycloak, Matrix, Django apps or the databases | [Application administration](./application-admin.md) |
| Change resource presets, domains or per-app limits        | [Configuration](./configuration.md)                  |
| Know which resources an application needs                 | [Per-app resources](./app-resources.md)              |
| Manage secrets, SOPS files or OpenBao                     | [Secrets](./secrets/index.md)                        |
| Operate PostgreSQL, Valkey and the object store           | [Datastores](./datastores/index.md)                  |
| Protect and restore data                                  | [Backup and restore](./backup-restore.md)            |
| Publish DNS records and certificates                      | [DNS](./dns.md)                                      |
| Monitor metrics, logs and traces                          | [Observability](./observability/index.md)            |
| Deploy into an air-gapped environment                     | [Airgap](./airgap.md)                                |
| Understand how Argo CD and Git drive the deployment       | [GitOps](./gitops.md)                                |
| Move to a newer release, or roll back                     | [Upgrades and rollback](./upgrades.md)               |
| A release does not converge                               | [Troubleshooting](./troubleshooting.md)              |

## Before you change anything

- **Back up first.** Most incidents during an upgrade become data loss without a
  recent backup and a tested restore. See
  [Backup and restore](./backup-restore.md).
- **Keep `MIJNBUREAU_MASTER_PASSWORD` stable.** It derives the database and
  identity provider credentials; rotating it locks users out of existing data.
- **Render before you apply.** `helmfile -e <environment> template` shows exactly
  what will change, without touching the cluster.
