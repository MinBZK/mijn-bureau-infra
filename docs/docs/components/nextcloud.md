# NextCloud

MijnBureau supplies an installation of [NextCloud](https://nextcloud.com/). NextCloud is an open-source file sharing and collaboration platform that enables secure storage, sharing, and collaboration on files and documents. Nextcloud has a high degree of flexibility and allows you to install many applications.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                                 | Description                                    |
| ------------------------------------ | ---------------------------------------------- |
| `global.domain`                      | The domain name of your MijnBureau instance    |
| `global.hostname.nextcloud`          | The subdomain name                             |
| `application.nextcloud.enabled`      | Enable NextCloud                               |
| `application.nextcloud.namespace`    | The Kubernetes namespace name                  |
| `secrets.nextcloud.*`                | Secrets for NextCloud                          |
| `tls.nextcloud.*`                    | The TLS settings                               |
| `authentication.client.nextcloud.*`  | The NextCloud OIDC clients created             |
| `authentication.oidc.*`              | The MijnBureau OIDC settings                   |
| `autoscaling.horizontal.nextcloud.*` | Scaling settings                               |
| `chart.nextcloud.*`                  | Chart settings to overwrite the charts         |
| `container.nextcloud.*`              | Container settings to overwrite                |
| `database.nextcloud.*`               | Database configuration                         |
| `pvc.nextcloud.*`                    | Storage configuration                          |
| `resources.nextcloud.*`              | Resource configuration                         |
| `objectstore.nextcloud.*`            | Object store configuration for primary storage |
| `smtp.*`                             | Mail settings for NextCloud notifications      |

## Key Features

NextCloud provides comprehensive file sharing and collaboration capabilities including:

- **File Management**: Secure storage and organization of files and folders
- **File Sharing**: Share files and folders with users, groups, or via public links
- **Collaborative Editing**: Real-time document collaboration with integrated office suite
- **Mobile & Desktop Sync**: Synchronization across devices with desktop and mobile clients
- **Version Control**: Automatic file versioning and restoration capabilities
- **External Storage**: Integration with external storage providers (MinIO, S3, etc.)
- **Apps Ecosystem**: Extensible with a wide range of applications and integrations

## Authentication Integration

NextCloud integrates with the MijnBureau authentication system through:

- **OIDC Authentication**: Seamless single sign-on using Keycloak
- **User Provisioning**: Automatic user account creation from OIDC identity provider
- **Group Mapping**: Synchronization of user groups and permissions

## Storage Configuration

NextCloud supports multiple storage backends:

- **Local Storage**: Standard Kubernetes persistent volumes for file storage
- **Object Storage**: Integration with MinIO or S3-compatible storage as primary storage
- **External Storage**: Mount external storage services as additional storage locations

The database, cache, and object store are automatically created when running in demo environment. For production environment you need to supply them separately.

> **Note:** For optimal NextCloud operation, ensure that your PVC datastore supports `ReadWriteMany` access mode. Without this configuration, scheduled tasks (cronjobs) will not function correctly.

## Email Configuration

NextCloud can send notifications and sharing invitations via email when SMTP settings are configured in the `smtp.*` configuration section.
