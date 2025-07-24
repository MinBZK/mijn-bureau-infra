# Matrix Chat with Synapse and Element

MijnBureau supplies an installation of [Matrix](https://matrix.org/) based chat. The reference Homeserver implementation
[Synapse](https://element-hq.github.io/synapse/latest/) is combined with the [Element](https://element.io/) chat web client.

## Configuration

To configure this solution, you can override the default settings for your
[selected environment](https://minbzk.github.io/mijn-bureau-infra/docs/category/installation). The defaults are
located in the folder `helmfile/environments/default`.

| Name                              | Description                                                  |
| --------------------------------- | ------------------------------------------------------------ |
| `global.domain`                   | The domain name of your MijnBureau instance                  |
| `global.matrixDomain`             | The server name of your Matrix instance                      |
| `global.hostname.element`         | The name of the subdomain for the Element web client         |
| `global.hostname.synapse`         | The name of the subdomain for the Synapse Matrix home server |
| `application.chat.enabled`        | Enable Matrix chat for your MijnBureau implementation        |
| `application.chat.namespace`      | The Kubernetes namespace name                                |
| `cache.synapse.*`                 | Connection to the Redis server                               |
| `authentication.client.synapse.*` | OpenIDC configuration to connect with Keycloak               |
| `database.synapse.*`              | Connection to the database                                   |
| `persistence.synapse.*`           | Storage configuration                                        |
| `resources.synapse.*`             | Resource configuration for synapse containers                |
| `secrets.synapse.*`               | Secretes for Synapse                                         |
| `smtp.*`                          | The mail settings for MijnBureau                             |
| `tls.synapse.*`                   | The TLS settings for Synapse                                 |
| `tls.chat.*`                      | The TLS settings for Element web                             |

# More information

- [Synapse Configuration Manual](https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html)
- [Element web](https://web-docs.element.dev/Element%20Web/config.html)
