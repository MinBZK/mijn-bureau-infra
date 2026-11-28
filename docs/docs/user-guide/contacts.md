---
sidebar_position: 160
---

# Contacts

Contacts is the shared address book. It stores your personal contacts next to the
organization-wide directory, and it feeds the people and group suggestions in the other
LaSuite apps.

Open Contacts from the app launcher at `contacts.<your-domain>`.

Contacts is disabled by default in MijnBureau. If the tile is missing, your
administrator has not enabled it yet; see the
[component documentation](../components/contacts.md) for the deployment status.

## Contacts

- Create a contact with a name, email addresses, phone numbers, organizations and labels.
- Mark contacts as favorites for quick access.
- Import and export vCard (`.vcf`) and CSV files.
- Deleted contacts stay in the trash for the configured retention period; restore them or
  delete them permanently.

## Groups and labels

Use groups to keep related contacts together and labels to tag them. Organization
contacts are visible to everyone; personal contacts are only visible to you.

## CardDAV

Phones and desktop address books can sync over CardDAV with your Contacts credentials.
The discovery URL is `https://contacts.<your-domain>/.well-known/carddav`.

## Suggestions in other apps

Docs, Drive, Messages and Calendars query Contacts for people and group suggestions when
you share a document or address a message. The integration uses your own access token, so
you only see contacts you are allowed to see.

- [Component documentation](../components/contacts.md) — how Contacts is deployed
