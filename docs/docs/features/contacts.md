# Contacts and address book

MijnBureau includes **Contacts**, the shared address book from LaSuite. It stores
personal and organization-wide contacts, groups and labels, and serves the people and
group suggestions that other LaSuite apps show while sharing or addressing mail.

Contacts is disabled by default (`application.contacts.enabled: false`) because the
upstream project only publishes mutable `main` image tags, currently in a private GHCR
package. Enable it once those images are public or the cluster has a GHCR image pull
secret.

## What you can do

- Create, edit and organize contacts, groups and labels.
- Keep favorites, search contacts, and import/export vCard (`.vcf`) and CSV files.
- Restore deleted contacts from the trash within the retention period.
- Sync phones and desktop address books over CardDAV.
- Feed people and group suggestions to Docs, Drive, Messages and Calendars through the
  external API.

## Deployment

The chart deploys three workloads:

- `backend`, the Django API and admin.
- `worker`, the Dramatiq worker that imports files and purges trash and CardDAV changes.
- `frontend`, Caddy serving the SPA and proxying the backend paths.

Contacts needs PostgreSQL and Redis (Valkey in the demo environment). Unlike the other
LaSuite apps it keeps contact photos inline and serves its static assets from the image, so
it does not use the bundled S3 object store.

## Relation to identity

Users authenticate through Keycloak. Contacts is not an identity provider; it stores
address book data around the Keycloak accounts and uses the configured OIDC claim to
resolve organizations.

- [Multi-tenancy and organizations](../security/multi-tenancy.md)
- [Contacts upstream repository](https://github.com/suitenumerique/contacts)
