---
sidebar_position: 20
---

# Administration

This page is about getting in: which admin surface exists, which account it uses,
where the password comes from, and how to recover access when something is
locked.

There are two layers of administration:

- **Cluster level** - `kubectl` and `helmfile`. Whoever can run these owns the
  deployment; there is no web UI for the cluster itself.
- **Application level** - per-product admin accounts. Almost every one of them is
  derived from `MIJNBUREAU_MASTER_PASSWORD` (see
  [Secrets](./secrets/index.md)), so no password has to be stored.

For administering what is inside each application - Keycloak realms, Matrix
users, Django admin, databases - see [Application administration](./application-admin.md).

:::warning
All derived passwords change when `MIJNBUREAU_MASTER_PASSWORD` changes. That
rotates every database password, app secret and admin login at once. Read
[Secrets](./secrets/index.md) before you touch it.
:::

## Admin surfaces at a glance

| Surface                                                                                                                      | Where                                                                                                                    | Account                                                      | Password source                  |
| ---------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------ | -------------------------------- |
| Keycloak admin console                                                                                                       | `https://id.<global.domain>/admin` (realm `mijnbureau`)                                                                  | `admin`                                                      | `secret.keycloak.adminPassword`  |
| Ketesa (Synapse admin UI)                                                                                                    | `https://ketesa.<global.domain>`                                                                                         | Matrix account that is **Synapse admin** _and_ **MAS admin** | the user's Keycloak password     |
| MAS account UI                                                                                                               | `https://mas.<global.domain>/`                                                                                           | any end user                                                 | Keycloak                         |
| Nextcloud _(when `application.nextcloud.enabled`)_                                                                           | `https://nextcloud.<global.domain>/settings/admin`                                                                       | `admin`                                                      | `secret.nextcloud.adminPassword` |
| LaSuite Django admins (Docs, Drive, Meet, Conversations, Projects, Contacts, Calendars, Dictaphone, Messages, Find, Menshen) | not publicly routed — port-forward, see [LaSuite applications](./application-admin.md#lasuite-applications-django-admin) | per app, see table below                                     | `secret.<app>.*`                 |
| Object store consoles (per app)                                                                                              | not publicly routed                                                                                                      | n/a                                                          | `objectstore.<app>.secretKey`    |
| PostgreSQL (CloudNativePG)                                                                                                   | no UI — `psql` in the cluster                                                                                            | `postgres`                                                   | `<app>-cluster-superuser` secret |
| LiveKit (SFU)                                                                                                                | no admin UI                                                                                                              | —                                                            | `application.livekit.keys`       |

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
