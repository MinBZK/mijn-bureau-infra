# docs

MijnBureau supplies an installation of [Docs](https://github.com/suitenumerique/docs). It is a collaborative note solution.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                         | Description                                    |
| ---------------------------- | ---------------------------------------------- |
| `global.domain`              | The domain name of your MijnBureau instance    |
| `global.hostname.docs`       | The name of the subdomain for the docs client  |
| `application.docs.enabled`   | Enable docs for your MijnBureau implementation |
| `application.docs.namespace` | The Kubernetes namespace name                  |
| `application.docs.*`         | Specific docs configuration options            |
| `ai.llm.*`                   | Docs can make use of the configured AI model   |
| `authorization.docs.*`       | Authentication configration                    |
| `autoscaling.*.docs.*`       | Autoscaling (horizontal and vertical)          |
| `cache.docs.*`               | Cache configuration                            |
| `container.docs.*`           | Container selection                            |
| `database.docs.*`            | Database configuration                         |
| `objectstore.docs.*`         | Object store (S3) configuration                |
| `pvc.docs.*`                 | Persistent Volume Claim configuration          |
| `resource.docs.*`            | Resources                                      |
| `secret.docs.*`              | Superuser credentials                          |
| `tls.docs.*`                 | The TLS settings                               |

## More information

A collaborative note taking, wiki and documentation platform that scales. Built with Django and React.

For more details, or to request additional features, please refer to the official [docs documentation](https://github.com/suitenumerique/docs).
