# Grist

MijnBureau supplies an installation of [Grist](https://www.getgrist.com/). Grist is an Collaborative spreadsheet tool. Grist also has a [desktop app](https://github.com/gristlabs/grist-desktop?tab=readme-ov-file) available.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                             | Description                                 |
| -------------------------------- | ------------------------------------------- |
| `global.domain`                  | The domain name of your MijnBureau instance |
| `global.hostname.grist`          | The subdomain name                          |
| `application.grist.enabled`      | Enable grist                                |
| `application.grist.namespace`    | The Kubernetes namespace name               |
| `secrets.grist.*`                | Secrets for grist                           |
| `smtp.*`                         | The mail settings for MijnBureau            |
| `tls.grist.*`                    | The TLS settings                            |
| `authentication.client.grist.*`  | The grist clients created                   |
| `autoscaling.horizontal.grist.*` | Scaling settings                            |
| `chart.grist.*`                  | Chart settings to overwrite the charts      |
| `container.grist.*`              | Container settings to overwrite             |
| `database.grist.*`               | Database configuration                      |
| `pvc.grist.*`                    | Storage configuration                       |
| `resources.grist.*`              | Resource configuration                      |
| `objectstore.grist.*`            | Object configuration                        |
| `license.grist.*`                | License setup for enterprise features       |

The database, cache and object store are automaticly created when running in demo environment. For production environment you need to supply it.
