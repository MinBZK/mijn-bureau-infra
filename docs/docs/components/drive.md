# Meet

MijnBureau supplies an installation of [Drive](https://github.com/suitenumerique/drive). It is a filestorage solutions that uses S3 and can be seen as a simpelere alternative to nextcloud files.

## Configuration

To configure this solution, you can override the default settings for your
[selected environment](https://minbzk.github.io/mijn-bureau-infra/docs/category/installation). The defaults are
located in the folder `helmfile/environments/default`.

| Name                             | Description                                    |
| -------------------------------- | ---------------------------------------------- |
| `global.domain`                  | The domain name of your MijnBureau instance    |
| `global.hostname.drive`          | The name of the subdomain for the meet client  |
| `application.drive.enabled`      | Enable meet for your MijnBureau implementation |
| `application.drive.namespace`    | The Kubernetes namespace name                  |
| `authorization.drive.enabled`    | Enable meet for your MijnBureau implementation |
| `tls.drive.*`                    | The TLS settings for meet                      |
| `pvc.drive.*`                    | storage requirements                           |
| `resources.drive.*`              | Resources for meet                             |
| `autoscaling.horizontal.drive.*` | Autoscaling for meet.                          |
| `container.drive.*`              | Container selection                            |
| `secret.drive.*`                 | Superuser credentials                          |

## More information

**La Suite Drive** is a collaborative file sharing platform designed for seamless teamwork. It enables teams to securely store, share, and collaborate on files, all while retaining full control over their data. Drive offers a user-friendly, open-source solution that prioritizes privacy and flexibility for organizations.
