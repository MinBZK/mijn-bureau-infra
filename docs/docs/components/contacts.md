---
sidebar_position: 95
---

# Contacts

_Where this fits: this page covers deployment. How to use it: [Contacts](../user-guide/contacts.md)._

MijnBureau supplies an installation of [Contacts](https://github.com/suitenumerique/contacts),
the shared address book from LaSuite. It stores personal and organisation-wide contacts,
groups and labels, and serves the people and group suggestions that Docs, Drive, Messages and
Calendars show while sharing or addressing mail.

## Availability

Contacts is **disabled by default** (`application.contacts.enabled: false`). The upstream
project only publishes mutable `main` image tags in a private GHCR package at the moment.
Enable it once those images are public, or when the cluster has a GHCR image pull secret.

## Configuration

To configure this solution, you can override the default settings for your environment. The
defaults are located in the folder `helmfile/environments/default`.

| Name                               | Description                                    |
| ---------------------------------- | ---------------------------------------------- |
| `global.domain`                    | The domain name of your MijnBureau instance    |
| `global.hostname.contacts`         | The subdomain of the Contacts frontend and API |
| `application.contacts.enabled`     | Enable Contacts                                |
| `application.contacts.namespace`   | The Kubernetes namespace name                  |
| `application.contacts.secretKey`   | Django secret key                              |
| `application.contacts.saltKey`     | Salt used to encrypt sensitive fields          |
| `authentication.client.contacts.*` | OIDC client credentials                        |
| `database.contacts.*`              | PostgreSQL connection details                  |
| `cache.contacts.*`                 | Valkey connection details                      |
| `pvc.contacts.*`                   | Storage requirements for PostgreSQL and Valkey |
| `resource.contacts.*`              | Resources for each component                   |
| `container.contacts_*`             | Container image selection                      |

## Components

| Component | Description                                                    |
| --------- | -------------------------------------------------------------- |
| Backend   | Django API and admin                                           |
| Worker    | Dramatiq worker for imports, trash purge and CardDAV changes   |
| Frontend  | Caddy serving the single-page application and proxying the API |

Contacts needs PostgreSQL and Valkey. Unlike the other LaSuite applications it keeps contact
photos inline and serves its static assets from the image, so it does not use the object
store.

## Relation to identity

Users authenticate through Keycloak; Contacts is not an identity provider. It stores address
book data around the Keycloak accounts and uses the configured OIDC claim to resolve
organisations.

## More information

- [Upstream repository](https://github.com/suitenumerique/contacts)
- [Multi-tenancy and organisations](../security/multi-tenancy.md)
