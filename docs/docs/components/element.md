---
sidebar_position: 120
---

# Element

_Where this fits: this page covers deployment. How to use it: [Chat (Element)](../user-guide/element.md)._

MijnBureau supplies an installation of [Matrix](https://matrix.org/) based chat. [Element Synapse](https://element-hq.github.io/synapse/latest/) is combined with the [Element Web](https://element.io/) chat web client. Their are also [desktop and mobile apps](https://matrix.org/ecosystem/clients/) available to connect to Synapse directly

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                                 | Description                                                  |
| ------------------------------------ | ------------------------------------------------------------ |
| `global.domain`                      | The domain name of your MijnBureau instance                  |
| `global.matrixDomain`                | The server name of your Matrix instance                      |
| `global.hostname.element`            | The name of the subdomain for the Element web client         |
| `global.hostname.synapse`            | The name of the subdomain for the Synapse Matrix home server |
| `global.hostname.mas`                | The name of the subdomain for the MAS authentication service |
| `global.hostname.ketesa`             | The name of the subdomain for the Ketesa admin UI            |
| `application.element.enabled`        | Enable Matrix chat for your MijnBureau implementation        |
| `application.element.call.enabled`   | Enable Element Call (MatrixRTC) in-app calls (default: true) |
| `application.element.call.*`         | Element Call settings (as/hs appservice tokens)              |
| `application.element.namespace`      | The Kubernetes namespace name                                |
| `application.element.mas.enabled`    | Deploy the Matrix Authentication Service (default: true)     |
| `application.element.mas.*`          | MAS settings (shared secret, compat client ULID)             |
| `application.element.ketesa.enabled` | Deploy the Ketesa admin UI (default: false)                  |
| `authentication.client.synapse.*`    | OpenIDC configuration to connect with Keycloak               |
| `authentication.client.mas.*`        | OIDC client configuration for MAS                            |
| `database.synapse.*`                 | Connection to the database                                   |
| `database.mas.*`                     | Connection to the MAS database                               |
| `cache.synapse.*`                    | Connection to the Valkey server                              |
| `pvc.synapse.*`                      | Storage configuration                                        |
| `resource.synapse.*`                 | Resource configuration for synapse containers                |
| `smtp.*`                             | The mail settings for MijnBureau                             |
| `tls.synapse.*`                      | The TLS settings for Synapse                                 |
| `tls.element.*`                      | The TLS settings for Element web                             |
| `autoscaling.horizontal.element.*`   | Autoscaling for element web                                  |
| `autoscaling.vertical.synapse.*`     | Autoscaling for synapse                                      |
| `container.elementweb.*`             | Container selection                                          |
| `container.synapse.*`                | Container selection                                          |
| `container.matrix_auth_service.*`    | MAS container selection                                      |
| `container.ketesa.*`                 | Ketesa admin UI container selection                          |
| `container.element_call.*`           | Element Call SPA container selection                         |
| `container.lk_jwt_service.*`         | LiveKit JWT service container selection                      |

The database and cache are automatically created when running in demo environment. For production environment you need to supply your own.

## Element Call (MatrixRTC)

With `application.element.call.enabled` (default: true) MijnBureau deploys the
MatrixRTC calling stack:

- the [Element Call SPA](https://github.com/element-hq/element-call)
  (`element-call.<global.domain>`, image `ghcr.io/element-hq/element-call`),
  which Element Web embeds for group calls via its `element_call` config,
- the [lk-jwt-service](https://github.com/element-hq/lk-jwt-service)
  MatrixRTC authorization service (`livekit-jwt.<global.domain>`), which
  verifies Matrix OpenID tokens and mints LiveKit JWTs. It uses the dedicated
  `elementcall` key from `application.livekit.keys` — separate from the key
  Meet uses — against the shared LiveKit SFU. It runs as a Synapse
  application service (MSC4502/MSC4512): Synapse proxies the
  `/rtc/livekit` endpoints to it and it verifies room membership before
  issuing tokens. The as/hs tokens come from `application.element.call.*`,
  and the registration file is rendered into the synapse secrets volume,
- a Synapse `matrix_rtc.transports` entry for the matrixrtc transports
  endpoint, plus an `org.matrix.msc4143.rtc_foci` well-known fallback for
  older clients.

Both hostnames need their own DNS records (see [DNS](../operating/dns.md)).

## Matrix Authentication Service (MAS)

By default the element app also deploys the [Matrix Authentication Service](https://element-hq.github.io/matrix-authentication-service/) (`application.element.mas.enabled: true`). MAS is the OIDC broker required for native clients such as Element X: Synapse delegates authentication to it via MSC3861. The MAS deployment gets:

- its own release `element-mas` and a CloudNativePG credential/cluster release (`mas-cluster-credentials`) in the demo environment,
- a dedicated hostname `mas.<global.domain>` (requires its own DNS record — see [DNS](../operating/dns.md)),
- OIDC credentials from `authentication.client.mas.*`,
- its database connection from `database.mas.*`,
- the MAS admin API on the public listener when `application.element.ketesa.enabled`
  is set (`charts/mas` `config.adminApi.enabled`), so Ketesa can manage MAS
  sessions, linked email addresses and registration tokens.

## Admin UI (Ketesa)

With `application.element.ketesa.enabled` (default: false) MijnBureau deploys
[Ketesa](https://github.com/etkecc/ketesa), the open source admin UI for
Synapse that grew out of `synapse-admin`. It runs as the `ketesa` release in the
element namespace, at `ketesa.<global.domain>` (needs its own DNS record, see
[DNS](../operating/dns.md)), from the `ghcr.io/etkecc/ketesa` image.

Ketesa is a static single page application: there is no backend, no database
and no additional credentials. The browser calls the homeserver's
`/_synapse/admin` API directly, so an operator signs in with a Synapse admin
account (password, or an access token when authentication is delegated) and
needs network access to `https://matrix.<global.domain>`.

The rendered `config.json` (see `helmfile/apps/element/values-ketesa.yaml.gotmpl`)
sets:

- `restrictBaseUrl` to this homeserver, so the panel cannot be used to drive an
  arbitrary Matrix server from a MijnBureau hostname,
- `externalAuthProvider: true`, because Synapse has password login disabled and
  delegates authentication to MAS/Keycloak.

Because the panel is a privileged surface, it is deployed with a read-only root
filesystem, no service account token, no egress beyond DNS and no ingress from
other pods (only through the gateway).

MAS-backed management (sessions, linked emails, upstream OAuth links,
registration tokens) needs a MAS admin account in addition to a Synapse admin.
The panel talks to the MAS admin API, which this app exposes on the MAS listener
when Ketesa is enabled. See [Administration](../operating/administration.md) for promoting
both kinds of admin, the `mas-cli` commands and the other products' admin UIs.

## More information

- [Synapse Configuration Manual](https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html)
- [Element web](https://web-docs.element.dev/Element%20Web/config.html)
