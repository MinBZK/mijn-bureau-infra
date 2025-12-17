# OpenProject

MijnBureau supplies an installation of [OpenProject](https://www.openproject.org/). OpenProject is an open-source project management platform for planning, tracking, and collaborating on projects.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                                   | Description                                 |
| -------------------------------------- | ------------------------------------------- |
| `global.domain`                        | The domain name of your MijnBureau instance |
| `global.hostname.openproject`          | The subdomain name                          |
| `application.openproject.enabled`      | Enable openproject                          |
| `application.openproject.namespace`    | The Kubernetes namespace name               |
| `secrets.openproject.*`                | Secrets for openproject                     |
| `smtp.*`                               | The mail settings for MijnBureau            |
| `tls.openproject.*`                    | The TLS settings                            |
| `authentication.client.openproject.*`  | The openproject clients created             |
| `autoscaling.horizontal.openproject.*` | Scaling settings                            |
| `container.openproject.*`              | Container settings to overwrite             |
| `database.openproject.*`               | Database configuration                      |
| `cache.openproject.*`                  | Cache configuration                         |
| `pvc.openproject.*`                    | Storage configuration                       |
| `resources.openproject.*`              | Resource configuration                      |
| `objectstore.openproject.*`            | Object configuration                        |

The database, cache and object store are automatically created when running in demo environment. For production environment you need to supply it.

## Authentication Integration

OpenProject integrates with MijnBureau authentication via:

- **OIDC Authentication**: Single sign-on using Keycloak
- **User Provisioning**: Automatic account creation from OIDC provider
- **Group Mapping**: Synchronization of user groups and permissions

The internal authentication mechanism is bypassed to enable direct Single sign-on. To login with an internal user (for instance the admin user) use the URL: `https://<global.hostname.openproject>.<global.domain>/login/internal`
