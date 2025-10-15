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
| `application.chat.enabled`         | Enable Matrix chat for your MijnBureau implementation        |
| `application.chat.namespace`       | The Kubernetes namespace name                                |
| `cache.synapse.*`                  | Connection to the Redis server                               |
| `authentication.client.synapse.*`  | OpenIDC configuration to connect with Keycloak               |
| `database.synapse.*`               | Connection to the database                                   |
| `cache.synapse.*`                  | Connection to a cache system                                 |
| `pvc.synapse.*`                    | Storage configuration                                        |
| `resources.synapse.*`              | Resource configuration for synapse containers                |
| `smtp.*`                           | The mail settings for MijnBureau                             |
| `tls.synapse.*`                    | The TLS settings for Synapse                                 |
| `tls.chat.*`                       | The TLS settings for Element web                             |
| `autoscaling.horizontal.element.*` | Autoscaling for element web                                  |
| `autoscaling.vertical.synapse.*`   | Autoscaling for synapse                                      |
| `container.elementweb.*`           | Container selection                                          |
| `container.synapse.*`              | Container selection                                          |

The database and cache are automatically created when running in demo environment. For production environment you need to supply your own.

## More information

- [Synapse Configuration Manual](https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html)
- [Element web](https://web-docs.element.dev/Element%20Web/config.html)
