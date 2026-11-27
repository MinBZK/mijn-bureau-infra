---
sidebar_position: 8
---

# Administration

This page lists the administrative surfaces of a MijnBureau deployment: which
admin UI exists for which product, which account it uses, and where that
password comes from.

There are two layers of administration:

- **Cluster level** — `kubectl` and `helmfile`. Whoever can run these owns the
  deployment; there is no web UI for the cluster itself.
- **Application level** — per-product admin accounts, described below. Almost
  every one of them is derived from `MIJNBUREAU_MASTER_PASSWORD` (see
  [Secrets](./secrets/index.md)), so no password has to be stored.

Instructions for the people who _use_ the suite (not administer it) live in the
[User guide](./user-guide/index.md).

:::warning
All derived passwords change when `MIJNBUREAU_MASTER_PASSWORD` changes. That
rotates every database password, app secret and admin login at once. Read
[Secrets](./secrets/index.md) before you touch it.
:::

## Admin surfaces at a glance

| Surface                                                                                                                      | Where                                                                                              | Account                                                      | Password source                  |
| ---------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ | -------------------------------- |
| Keycloak admin console                                                                                                       | `https://id.<global.domain>/admin` (realm `mijnbureau`)                                            | `admin`                                                      | `secret.keycloak.adminPassword`  |
| Ketesa (Synapse admin UI)                                                                                                    | `https://ketesa.<global.domain>`                                                                   | Matrix account that is **Synapse admin** _and_ **MAS admin** | the user's Keycloak password     |
| MAS account UI                                                                                                               | `https://mas.<global.domain>/`                                                                     | any end user                                                 | Keycloak                         |
| Nextcloud _(when `application.nextcloud.enabled`)_                                                                           | `https://nextcloud.<global.domain>/settings/admin`                                                 | `admin`                                                      | `secret.nextcloud.adminPassword` |
| LaSuite Django admins (Docs, Drive, Meet, Conversations, Projects, Contacts, Calendars, Dictaphone, Messages, Find, Menshen) | not publicly routed — port-forward, see [LaSuite applications](#lasuite-applications-django-admin) | per app, see table below                                     | `secret.<app>.*`                 |
| Object store consoles (per app)                                                                                              | not publicly routed                                                                                | n/a                                                          | `objectstore.<app>.secretKey`    |
| PostgreSQL (CloudNativePG)                                                                                                   | no UI — `psql` in the cluster                                                                      | `postgres`                                                   | `<app>-cluster-superuser` secret |
| LiveKit (SFU)                                                                                                                | no admin UI                                                                                        | —                                                            | `application.livekit.keys`       |

`secret.*` refers to `helmfile/environments/default/secret.yaml.gotmpl`; every
entry there is derived with
`{{ derivePassword 1 "long" (requiredEnv "MIJNBUREAU_MASTER_PASSWORD") "<app>" "<key>" | sha1sum }}`.
Override an entry in your environment file under `secret:` to pin a specific
password instead of a derived one.

## Reading a password from the cluster

Most products store their admin password in a Kubernetes Secret, so you can
always recover it from the running deployment:

```bash
# Keycloak admin password
kubectl -n mijnbureau-keycloak get secret keycloak-keycloak \
  -o jsonpath='{.data.admin-password}' | base64 -d; echo

# Django superuser credentials of an app (example: Meet)
kubectl -n mijnbureau-meet get secret meet-superuser -o json \
  | jq -r '.data | to_entries[] | "\(.key)=\(.value|@base64d)"'
```

The same works with `helmfile template` if you prefer to keep the password out
of the cluster:

```bash
MIJNBUREAU_MASTER_PASSWORD=... helmfile -e demo template \
  | yq 'select(.kind == "Secret" and .metadata.name == "keycloak-keycloak")'
```

## Matrix and Element

Element/Matrix has no single admin account: Synapse and MAS (Matrix
Authentication Service) keep their own admin flags, and both are needed for the
full admin experience.

| Flag                 | Managed in                       | Grants                                                             |
| -------------------- | -------------------------------- | ------------------------------------------------------------------ |
| Synapse server admin | Synapse database (`users.admin`) | users, rooms, media, federation, reports                           |
| MAS admin            | MAS database, via `mas-cli`      | sessions, linked emails, upstream OAuth links, registration tokens |

All Matrix accounts live in Keycloak (MAS delegates sign-in to it), so the
login password of an admin is a normal Keycloak user password — there is no
separate "Synapse admin password".

### Ketesa (admin UI)

`application.element.ketesa.enabled` deploys
[Ketesa](https://github.com/etkecc/ketesa) at `ketesa.<global.domain>`. It is a
static SPA: it keeps no accounts and stores nothing, the browser calls the
homeserver's `/_synapse/admin` (and MAS admin) API directly with the token of
the user who signed in.

Sign in either through MAS/Keycloak, or with an access token pasted from
Element Web (_Settings → Help & About → Access token_). After promoting an
account to admin you must sign out and back in: the admin scope is part of the
issued token.

### Promoting a Synapse server admin

Inspect who is admin:

```bash
kubectl -n mijnbureau-element exec element-cluster-1 -- psql -U postgres -d synapse \
  -tAc "select name, admin, deactivated from users order by name;"
```

Promote (or demote) an account:

```bash
kubectl -n mijnbureau-element exec element-cluster-1 -- psql -U postgres -d synapse \
  -c "update users set admin = 1 where name = '@janedoe:matrix.open-desk.nl';"
```

The flag is read per request, so no restart is needed. The account must exist
first — a user is only created in Synapse after their first sign-in through
Element. SQL is the bootstrap path: while no admin exists, the admin API itself
cannot be used to create one.

### Promoting a MAS admin

```bash
MAS_ARGS="--config /config/config.yaml --config /etc/mas/secrets.yaml"

# Who can request admin privileges
kubectl -n mijnbureau-element exec deploy/element-mas -- mas-cli manage $MAS_ARGS list-admin-users

# Promote / demote
kubectl -n mijnbureau-element exec deploy/element-mas -- mas-cli manage $MAS_ARGS promote-admin janedoe
kubectl -n mijnbureau-element exec deploy/element-mas -- mas-cli manage $MAS_ARGS demote-admin janedoe
```

`promote-admin` takes the bare localpart (`janedoe`), not the full
`@janedoe:<domain>` MXID — the full form fails with `User not found`. The user
must have completed a MAS sign-in at least once.

Other useful `mas-cli manage` commands:

| Command                         | What it does                                                |
| ------------------------------- | ----------------------------------------------------------- |
| `issue-user-registration-token` | Create a registration token for onboarding users            |
| `kill-sessions --user-id <id>`  | Force re-authentication (revoke sessions)                   |
| `lock-user` / `unlock-user`     | Temporarily block sign-in                                   |
| `set-password`                  | Set a local password (only useful with `passwords.enabled`) |
| `register-user`                 | Create a user without the sign-in flow                      |

The MAS admin API, which Ketesa's MAS tabs use, is exposed on the public MAS
listener only while Ketesa is enabled (`charts/mas` `config.adminApi.enabled`,
threaded from `application.element.ketesa.enabled`). It is authenticated and
answers MAS admins only.

### "Administrator access required"

Ketesa requests the `urn:mas:admin` scope when it signs in through MAS. If the
account is not a MAS admin, MAS renders its `policy_violation` page:

> Administrator access required. This application requires administrator
> privileges. Sign in with an administrator account to continue.

That message comes from MAS, not from Ketesa — run `promote-admin` above and
sign in again. A Synapse admin alone is not enough for that flow.

## Keycloak

All application identities, sessions and per-app OIDC clients live in the
`mijnbureau` realm at `https://id.<global.domain>/admin` (the `master` realm
holds the `admin` account used to log in):

```bash
kubectl -n mijnbureau-keycloak get secret keycloak-keycloak \
  -o jsonpath='{.data.admin-password}' | base64 -d; echo
```

Day-to-day tasks:

- **Users** — demo environments are seeded from the `user:` list in
  `helmfile/environments/default/user.yaml.gotmpl` (override per environment).
  The generated passwords are readable from the `keycloak-config-cli` Secret:

  ```bash
  kubectl -n mijnbureau-keycloak get secret keycloak-config-cli -o json \
    | jq -r '.data | to_entries[] | select(.key|startswith("MB_USER_PASSWORD"))
             | "\(.key|sub("MB_USER_PASSWORD_";""))=\(.value|@base64d)"'
  ```

- **Clients** — one OIDC client per product (`synapse`, `mas`, `docs`, `drive`,
  `meet`, …), defined in `helmfile/apps/keycloak/values-keycloak-config-cli.yaml.gotmpl`.
  Their secrets are derived from the master password and also exposed as
  `MB_CLIENT_SECRET_*` keys in the same Secret.
- **Groups and roles** — realm roles are used for per-app access (see
  [Identity federation](./security/identity-federation.md)); MijnBureau itself
  does not map Keycloak roles to Synapse/MAS admin flags.

:::note
The realm is declarative. `keycloak-config-cli` reconciles it on every
`helmfile apply`, so manual changes made in the admin console may be reverted.
Add users, clients and roles in the values file instead.
:::

## LaSuite applications (Django admin)

Docs, Drive, Meet, Conversations, Projects, Contacts, Calendars, Dictaphone,
Messages, Find and Menshen are Django applications with a full Django admin.
That admin is **not exposed publicly** by default; the public hostnames only
serve the application (the SPA answers `/admin/` with its own 404 page).
Break-glass access is a port-forward to the backend service:

```bash
# https://docs.<domain> admin
kubectl -n mijnbureau-docs port-forward svc/docs-backend 8000:80
# then open http://localhost:8000/admin/

# Meet
kubectl -n mijnbureau-meet port-forward svc/meet-backend 8001:80
# Drive
kubectl -n mijnbureau-drive port-forward svc/drive-backend 8002:80
# Contacts
kubectl -n mijnbureau-contacts port-forward svc/contacts-backend 8003:80
# Conversations
kubectl -n mijnbureau-conversations port-forward svc/conversations-backend 8004:80
# Dictaphone
kubectl -n mijnbureau-dictaphone port-forward svc/dictaphone-backend 8005:80
# Calendars
kubectl -n mijnbureau-calendars port-forward svc/calendars-backend 8006:80
# Messages
kubectl -n mijnbureau-messages port-forward svc/messages-backend 8007:80
# Projects (single service)
kubectl -n mijnbureau-projects port-forward svc/projects 8008:80
# Find and Menshen (service listens on 8000)
kubectl -n mijnbureau-find port-forward svc/find 8009:8000
kubectl -n mijnbureau-find port-forward svc/menshen 8010:8000
```

Request access with the `Host` header the app expects if Django rejects the
request:

```bash
curl -H "Host: docs.<global.domain>" http://localhost:8000/admin/
```

Superuser accounts and where their passwords live:

| Application   | Secret            | Key                                                                                                |
| ------------- | ----------------- | -------------------------------------------------------------------------------------------------- |
| Docs          | `docs`            | `DJANGO_SUPERUSER_PASSWORD` (email `secret.docs.superUser.email`)                                  |
| Drive         | `drive-superuser` | `DJANGO_SUPERUSER_EMAIL`, `DJANGO_SUPERUSER_PASSWORD`                                              |
| Meet          | `meet-superuser`  | `DJANGO_SUPERUSER_EMAIL`, `DJANGO_SUPERUSER_PASSWORD`                                              |
| Contacts      | `contacts`        | `DJANGO_SUPERUSER_EMAIL`, `DJANGO_SUPERUSER_PASSWORD`                                              |
| Conversations | `conversations`   | `secret.conversations.adminUser` / `adminPassword`                                                 |
| Calendars     | `calendars`       | `secret.calendars.adminUser` / `adminPassword`                                                     |
| Dictaphone    | —                 | no superuser is created by default; run `python manage.py createsuperuser` in `dictaphone-backend` |
| Messages      | `messages`        | `secret.messages.adminUser` / `adminPassword`                                                      |
| Projects      | `projects`        | `DEFAULT_ADMIN_PASSWORD` (email `secret.projects.adminUser`)                                       |
| Find          | `find`            | `DJANGO_SUPERUSER_PASSWORD` (user `admin`)                                                         |
| Menshen       | `menshen`         | `DJANGO_SUPERUSER_PASSWORD` (user `admin`)                                                         |

The initial account is created by a Helm hook Job (`createsuperuser`) from the
derived secret, so it already exists after the first deployment; change the
password in the Django admin afterwards if you do not want the derived one.

Docs can publish its admin through the gateway instead, with the admin URL on
the same hostname and an `/admin` path prefix:

- Docs: `helmfile/apps/docs/values.yaml.gotmpl` → `ingressAdmin.enabled: true`

This creates a second route (`ingress-admin.yaml` / `httproute-admin.yaml`). For
the other products the port-forward above is the supported path.

## Object storage

Every application gets its own SeaweedFS instance (`docs-seaweedfs`, `drive-seaweedfs`,
`meet-seaweedfs`, …) with an S3 API. The S3 port is reachable in-cluster as
`<app>-seaweedfs:8333`; public hostnames (`<app>-objectstore.<domain>`) are only used for
presigned URLs and are routed through the Gateway.

SeaweedFS has no web console, so there is nothing to port-forward for browsing. Use any S3
client from a pod in the application namespace, for example:

```bash
kubectl -n mijnbureau-drive run --rm -it --image=amazon/aws-cli objstore-cli -- \
  --endpoint-url http://drive-seaweedfs:8333 s3 ls
```

Credentials are `admin` (or `objectstore.<app>.accessKey`) plus
`objectstore.<app>.secretKey`, both in
`helmfile/environments/default/objectstore.yaml.gotmpl` and derived from the
master password.

## Databases

PostgreSQL runs as CloudNativePG clusters. There is no web UI; use `psql`
against the primary pod, or the superuser secret to connect from elsewhere:

```bash
# Application database (example: Synapse)
kubectl -n mijnbureau-element exec element-cluster-1 -- psql -U postgres -d synapse

# Superuser credentials for remote access
kubectl -n mijnbureau-element get secret element-cluster-superuser -o json \
  | jq -r '.data | to_entries[] | "\(.key)=\(.value|@base64d)"'
```

Each app has a database named after the product (`synapse`, `mas`, `docs`,
`drive`, `meet`, …) and an app-level user whose password is
`database.<product>.password`. The `postgres` superuser of every cluster is
derived as `database.<product>.adminpassword`.

## Break-glass checklist

Keep this in mind when handing a deployment over:

1. Store `MIJNBUREAU_MASTER_PASSWORD` in a password manager. It is the only
   input needed to recover every derived credential. A machine-generated
   random value of at least 20 characters is required — never a human-chosen
   password (see [Secrets](./secrets/derived.md#master-password-strength)).
2. Keep at least one Keycloak admin (`admin` in the `master` realm) and one
   Matrix account that is both Synapse admin and MAS admin.
3. Access to `kubectl` in the target namespace is equivalent to full control.
   Treat the kubeconfig as the highest-privilege credential, not the passwords
   above.
4. Test the break-glass paths (port-forwards, `psql`, Keycloak admin login)
   before you need them.
