---
sidebar_position: 30
---

# Application administration

How to administer the products themselves once you can reach them: Matrix and
Element, Keycloak, the Django admin of the LaSuite applications, object storage
and the databases.

Getting access - admin surfaces, passwords and break-glass - is on
[Administration](./administration.md).

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
  [Identity federation](../security/identity-federation.md)); MijnBureau itself
  does not map Keycloak roles to Synapse/MAS admin flags.
- **Profile fields** — users cannot change any profile field (`username`, `email`,
  `firstName`, `lastName`) in the Account Console; only admins can edit them in
  the admin console. Changing these permissions means editing the
  `org.keycloak.userprofile.UserProfileProvider` component in the same values file.

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
