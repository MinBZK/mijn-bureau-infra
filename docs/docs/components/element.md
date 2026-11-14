# Element

MijnBureau supplies an installation of [Matrix](https://matrix.org/) based chat. [Element Synapse](https://element-hq.github.io/synapse/latest/) is combined with the [Element Web](https://element.io/) chat web client. Their are also [desktop and mobile apps](https://matrix.org/ecosystem/clients/) available to connect to Synapse directly

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                               | Description                                                  |
| ---------------------------------- | ------------------------------------------------------------ |
| `global.domain`                    | The domain name of your MijnBureau instance                  |
| `global.matrixDomain`              | The server name of your Matrix instance                      |
| `global.hostname.element`          | The name of the subdomain for the Element web client         |
| `global.hostname.synapse`          | The name of the subdomain for the Synapse Matrix home server |
| `global.hostname.mas`              | The name of the subdomain for the MAS authentication service |
| `application.element.enabled`      | Enable Matrix chat for your MijnBureau implementation        |
| `application.element.namespace`    | The Kubernetes namespace name                                |
| `application.element.mas.enabled`  | Deploy the Matrix Authentication Service (default: true)     |
| `application.element.mas.*`        | MAS settings (shared secret, compat client ULID)             |
| `authentication.client.synapse.*`  | OpenIDC configuration to connect with Keycloak               |
| `authentication.client.mas.*`      | OIDC client configuration for MAS                            |
| `database.synapse.*`               | Connection to the database                                   |
| `database.mas.*`                   | Connection to the MAS database                               |
| `cache.synapse.*`                  | Connection to the Valkey server                              |
| `pvc.synapse.*`                    | Storage configuration                                        |
| `resource.synapse.*`               | Resource configuration for synapse containers                |
| `smtp.*`                           | The mail settings for MijnBureau                             |
| `tls.synapse.*`                    | The TLS settings for Synapse                                 |
| `tls.element.*`                    | The TLS settings for Element web                             |
| `autoscaling.horizontal.element.*` | Autoscaling for element web                                  |
| `autoscaling.vertical.synapse.*`   | Autoscaling for synapse                                      |
| `container.elementweb.*`           | Container selection                                          |
| `container.synapse.*`              | Container selection                                          |
| `container.matrix_auth_service.*`  | MAS container selection                                      |

The database and cache are automatically created when running in demo environment. For production environment you need to supply your own.

## Matrix Authentication Service (MAS)

By default the element app also deploys the [Matrix Authentication Service](https://element-hq.github.io/matrix-authentication-service/) (`application.element.mas.enabled: true`). MAS is the OIDC broker required for native clients such as Element X: Synapse delegates authentication to it via MSC3861. The MAS deployment gets:

- its own release `element-mas` and a CloudNativePG credential/cluster release (`mas-cluster-credentials`) in the demo environment,
- a dedicated hostname `mas.<global.domain>` (requires its own DNS record — see [DNS](../dns.md)),
- OIDC credentials from `authentication.client.mas.*`,
- its database connection from `database.mas.*`.

## More information

- [Synapse Configuration Manual](https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html)
- [Element web](https://web-docs.element.dev/Element%20Web/config.html)
