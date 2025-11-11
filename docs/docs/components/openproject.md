# OpenProject

MijnBureau supplies an installation of [OpenProject](https://www.openproject.org/). OpenProject is an open-source project management platform for planning, tracking, and collaborating on projects.

## Configuration

To configure OpenProject, override the default settings for your environment. The defaults are located in `helmfile/environments/default`.

## Authentication Integration

OpenProject integrates with MijnBureau authentication via:

- **OIDC Authentication**: Single sign-on using Keycloak
- **User Provisioning**: Automatic account creation from OIDC provider
- **Group Mapping**: Synchronization of user groups and permissions

## Notes

> **Demo Environment:** Uses bundled PostgreSQL and memcached.
> **Production Environment:** Use external database/cache and configure OIDC authentication.
