# ADR-MB-016: Secrets derived from a master password

## Status

Accepted

## Context

A MijnBureau deployment needs hundreds of credentials: Keycloak admin, OIDC client
secrets, database passwords, object store keys, LiveKit keys, application secret keys and
per-user demo passwords. Requiring an operator to generate and store each value
individually makes installation error-prone and makes review of charts harder, because
values files would otherwise contain secrets.

At the same time, some secrets cannot be derived: SMTP relay credentials, external IdP
client secrets, LDAP bind passwords and API keys for AI providers.

## Decision

We will use a two-layer secret model.

1. **Derived secrets (default).** Every generated password is derived deterministically
   from `MIJNBUREAU_MASTER_PASSWORD` using
   `derivePassword 1 "long" $MIJNBUREAU_MASTER_PASSWORD "<app>" "<key>" | sha1sum`.
   There is no default value: every render requires the variable to be set.
2. **SOPS files (optional).** Values that cannot be derived are supplied through
   SOPS-encrypted `*.secrets.yaml` files loaded with helm-secrets, or through environment
   variables for the few inputs that are read directly (for example
   `MESSAGES_MTA_RELAY_PASSWORD`).

`MIJNBUREAU_MASTER_PASSWORD` is stable per deployment. Changing it rotates every derived
credential at once and breaks access to existing data.

## Consequences

**Pros:**

- ✅ Only one secret must be managed and backed up for a default deployment.
- ✅ Values files and rendered manifests can be reviewed without exposing credentials.
- ✅ Installing a demo or test environment requires a single exported variable.

**Cons:**

- ❌ Losing the master password means losing access to all derived credentials.
- ❌ Rotating a single credential requires an explicit override; the derivation itself is
  all-or-nothing.
- ❌ Derived secrets are not suitable for shared or externally managed services, which is
  why SOPS remains necessary.
- ❌ The master password is part of every render, so CI must inject it and must not log it.
