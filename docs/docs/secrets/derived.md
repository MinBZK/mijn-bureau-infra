---
sidebar_position: 2
---

# Derived secrets

Derived secrets are the default. Every password in
`helmfile/environments/default/secret.yaml.gotmpl` is generated with a template
call like:

```
{{ derivePassword 1 "long" (requiredEnv "MIJNBUREAU_MASTER_PASSWORD") "<app>" "<key>" | sha1sum }}
```

This means:

- Only `MIJNBUREAU_MASTER_PASSWORD` must be kept secret and stable. All logins (Keycloak admin, Nextcloud admin, database passwords, LiveKit keys, etc.) are reproducible from it.
- Changing `MIJNBUREAU_MASTER_PASSWORD` rotates **every** generated password and breaks access to existing data. Set it once for each deployment and keep it safe.
- Override an individual value in your environment values file (e.g. `helmfile/environments/production/mijnbureau.yaml.gotmpl`) under the `secret:` key if you want a specific password instead of a derived one.

## Master password strength

The master password is the single entropy source for every derived secret: if it is guessable, **every** application and database password is guessable via offline brute force from any single leaked hash. Requirements:

- **Minimum 20 characters**, machine-generated (do not pick one by hand).
- Use a cryptographically random generator, e.g.:

  ```bash
  openssl rand -base64 24   # 24 random bytes -> 32 chars of entropy
  ```

- Store it in a password manager or secrets vault; never in shell history, tickets, or chat.
- Never reuse it across deployments (demo / staging / production must have different master passwords).

Which product uses which derived password, and how to recover it from the running cluster, is listed in [Administration](../administration.md).

Optional secret inputs consumed from the environment:

- `MESSAGES_MTA_RELAY_PASSWORD` — SMTP relay password for Messages (only when `application.messages.relayHost` is set).

## When derived secrets are not enough

Derived secrets are deterministic and local: they cannot represent credentials
issued by an external system, and they cannot be rotated per credential. Use
[SOPS secrets files](./sops.md) for individual external values, or the
[External Secrets Operator](./external-secrets-operator.md) when a central
secret manager is the source of truth.
