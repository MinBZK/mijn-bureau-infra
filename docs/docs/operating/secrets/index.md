---
sidebar_position: 10
---

# Secrets

MijnBureau handles secrets in three ways. Each approach is documented on its own page:

| Approach                                                    | Default | Store                                              | Use when                                                                                                  |
| ----------------------------------------------------------- | ------- | -------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| [Derived secrets](./derived.md)                             | Yes     | `MIJNBUREAU_MASTER_PASSWORD`                       | Always. Every generated password is derived from the master password.                                     |
| [SOPS secrets files](./sops.md)                             | No      | Encrypted `*.secrets.yaml` files in the repository | A few values must be overridden per environment, for example SMTP relay or external provider credentials. |
| [External Secrets Operator](./external-secrets-operator.md) | No      | OpenBao KV v2, synced by ESO                       | Secrets are managed in a central secret manager instead of being derived or committed.                    |

The three options are not mutually exclusive: derived secrets are always the
baseline, SOPS files override individual values, and the External Secrets
Operator replaces the derived secrets for the resources it manages.
