# Drive

MijnBureau supplies an installation of [Drive](https://github.com/suitenumerique/drive). It is a filestorage solutions that uses S3 and can be seen as a simpelere alternative to nextcloud files.

## Configuration

To configure this solution, you can override the default settings for your
[selected environment](https://minbzk.github.io/mijn-bureau-infra/docs/category/installation). The defaults are
located in the folder `helmfile/environments/default`.

| Name                             | Description                                     |
| -------------------------------- | ----------------------------------------------- |
| `global.domain`                  | The domain name of your MijnBureau instance     |
| `global.hostname.drive`          | The name of the subdomain for the drive client  |
| `application.drive.enabled`      | Enable drive for your MijnBureau implementation |
| `application.drive.namespace`    | The Kubernetes namespace name                   |
| `authentication.client.drive.*`  | OIDC client configuration                       |
| `tls.drive.*`                    | The TLS settings for drive                      |
| `database.drive.*`               | Database configuration                          |
| `cache.drive.*`                  | Cache (Valkey) configuration                    |
| `objectstore.drive.*`            | Object store (S3/MinIO) configuration           |
| `pvc.drive.*`                    | storage requirements                            |
| `resource.drive.*`               | Resources for drive                             |
| `autoscaling.horizontal.drive.*` | Autoscaling for drive.                          |
| `container.drive_backend.*`      | Container selection (backend)                   |
| `container.drive_frontend.*`     | Container selection (frontend)                  |
| `secret.drive.*`                 | Superuser credentials                           |

## More information

**La Suite Drive** is a collaborative file sharing platform designed for seamless teamwork. It enables teams to securely store, share, and collaborate on files, all while retaining full control over their data. Drive offers a user-friendly, open-source solution that prioritizes privacy and flexibility for organizations.
