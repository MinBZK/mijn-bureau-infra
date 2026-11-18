---
sidebar_position: 7
---

# External secrets (OpenBao + External Secrets Operator)

MijnBureau can source its secrets from an external secret manager instead of
deriving them from `MIJNBUREAU_MASTER_PASSWORD`. The stack is:

- **OpenBao** — the source of truth. Secrets are stored (and generated) in an
  OpenBao KV v2 store.
- **External Secrets Operator (ESO)** — syncs OpenBao values into ordinary
  Kubernetes `Secret` objects via `ClusterSecretStore` + `ExternalSecret` CRs.
- **App charts** — consume the ESO-synced `Secret` (via `existingSecret` /
  `usersExistingSecret` / `secretKeyRef`) instead of rendering their own.

```
scripts/generate-openbao-secrets.sh  ──writes──▶  OpenBao KV v2
                                                   ▲
                       ClusterSecretStore `openbao` (K8s SA auth)
                                                   ▲
              ExternalSecret per app  ──syncs──▶  Kubernetes Secret
                                                   ▲
              app charts consume via existingSecret / secretKeyRef
```

## The switch

One flag in `helmfile/environments/default/secrets.yaml.gotmpl`:

```yaml
secrets:
  backend: derived      # derived (default) | external
  store:
    name: openbao
    server: "https://openbao.rijkwerk.nl/"
    mount: kv           # KV v2 mount
    pathPrefix: mijnbureau
    kubernetes:
      serviceAccount: external-secrets
      audience: vault
```

- `backend: derived` — current behaviour: every secret is derived from
  `MIJNBUREAU_MASTER_PASSWORD`, and charts render inline `Secret`s.
- `backend: external` — **every app** switches to OpenBao-backed secrets. The
  ClusterSecretStore and per-app ExternalSecrets are rendered, and the
  CNPG/valkey/minio charts stop rendering their inline `Secret`s.

There is no per-app opt-in: flipping `backend` to `external` affects all apps at
once.

## Generating secrets into OpenBao

```bash
export BAO_ADDR=https://openbao.rijkwerk.nl/
export BAO_TOKEN=<token-with-write-on-kv/mijnbureau/*>
export BAO_KV_MOUNT=kv                 # matches secrets.store.mount
./scripts/generate-openbao-secrets.sh  [--env demo] [--force] [--dry-run]
```

The script generates every secret **in its final form** (40/50/63-char hex,
Fernet keys, `msgk_` API keys, channel UUIDs) and writes them to
`kv/data/mijnbureau/<env>/<owner>/<key>`. It is idempotent (skips existing
values unless `--force`, which rotates and therefore breaks existing DB/app
access until the apps restart against the new values).

Secrets shared between apps (Keycloak client secrets, calendars↔messages channel
keys, …) are stored **once** under their owner path, so both sides read the same
value.

## ESO resources in the repo

- **Chart** `helmfile/apps/common/charts/externalsecret` renders a
  `ClusterSecretStore` and `ExternalSecret`s, with support for mixing static
  values (e.g. usernames) with remote refs.
- **Release** `openbao-store` (in
  `helmfile/apps/common/helmfile-externalsecret.yaml.gotmpl`) renders the
  cluster-scoped `ClusterSecretStore`, gated on `secrets.backend: external`.
- **Per-app release** `<app>-externalsecret` (in each
  `helmfile/apps/<app>/helmfile-child.yaml.gotmpl`) renders that app's
  `ExternalSecret`s in its namespace, gated on `secrets.backend: external` and
  the demo environment.

The `ClusterSecretStore` authenticates with OpenBao using the Kubernetes auth
method (ServiceAccount `external-secrets`), so ESO and that ServiceAccount/role
must exist in the cluster before enabling `external`.

## What is migrated

| Area | Mechanism |
|---|---|
| CNPG database credentials | `cnpg-cluster-credentials` chart stops rendering `-app` / `-superuser` Secrets; ESO syncs them from `<owner>/database` and `<owner>/database_admin` |
| Valkey | `auth.usersExistingSecret: <app>-valkey-auth` (key `default`) |
| MinIO | `auth.existingSecret: <app>-minio` (keys `root-user`, `root-password`) |

## Not yet migrated

The following are **still on the derived model** (and still require
`MIJNBUREAU_MASTER_PASSWORD`) even when `secrets.backend: external`:

- **Application-level secrets** of the Django/LaSuite apps — admin/superuser
  passwords, Django `SECRET_KEY`s, OIDC client secrets, Fernet keys, and the
  composed connection strings (`REDIS_URL`, `CELERY_BROKER_URL`) rendered into
  the per-app `Secret` (e.g. `drive`, `messages`, `calendars`). These contain
  values ESO cannot build from a single remote ref (they mix a secret with
  host/port/config), so they need per-app runtime composition rather than a flag
  flip.
- **External provider credentials** — the six values that cannot be randomly
  generated are written by the generator as **placeholders** and must be
  replaced with real values:

  ```
  kv/mijnbureau/<env>/ai/llm_apiKey
  kv/mijnbureau/<env>/ai/whisperx_apiKey
  kv/mijnbureau/<env>/ai/ocr_apiKey
  kv/mijnbureau/<env>/livekit/meet_apiKey
  kv/mijnbureau/<env>/livekit/meet_apiSecret
  kv/mijnbureau/<env>/smtp/password
  ```

  Overwrite them with:

  ```bash
  bao kv patch kv/mijnbureau/<env>/<owner> <key>=<real-value>
  ```

> **Note:** `MIJNBUREAU_MASTER_PASSWORD` is still required at render time even
> in `external` mode, because the not-yet-migrated derived values are still
> computed. It is ignored for the migrated infra secrets. Once the app-level
> secrets are migrated too, the master password can be dropped entirely.
