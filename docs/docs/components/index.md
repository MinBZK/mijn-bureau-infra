---
sidebar_position: 10
---

# Components

Each page describes one deployed component: what it is, which values it exposes,
how it connects to the rest of the platform, and any deployment caveats. Use it
when you deploy, configure or troubleshoot a specific chart.

For what a component does for an end user and how to use it, see
[Using MijnBureau](../user-guide/index.md).

## Identity and access

| Component                 | Role                                                                     |
| ------------------------- | ------------------------------------------------------------------------ |
| [Keycloak](./keycloak.md) | Identity provider, OIDC clients, realm configuration and user federation |

## Collaboration

| Component                     | Role                                                               |
| ----------------------------- | ------------------------------------------------------------------ |
| [Bureaublad](./bureaublad.md) | Start page with apps, search and the shared team directory         |
| [Docs](./docs.md)             | Documents, wikis and meeting notes, plus the collaboration backend |
| [Drive](./drive.md)           | File storage and sharing, with Collabora for Office files          |
| [Nextcloud](./nextcloud.md)   | Optional file sync and share, alternative to Drive                 |
| [Collabora](./collabora.md)   | In-browser Office editing for Drive and Docs                       |
| [Projects](./projects.md)     | Project plans, pages and tasks                                     |
| [Calendars](./calendars.md)   | Shared calendars and booking links                                 |
| [Contacts](./contacts.md)     | Shared address books and groups                                    |
| [Find](./find.md)             | Cross-application search API                                       |

## Communication

| Component                 | Role                                                          |
| ------------------------- | ------------------------------------------------------------- |
| [Element](./element.md)   | Matrix chat client, Synapse homeserver and MAS authentication |
| [Messages](./messages.md) | Mail backend, MTA, spam filtering and mail domains            |
| [Meet](./meet.md)         | Video conferencing with recording                             |
| [Livekit](./livekit.md)   | WebRTC media backend for Meet and Element Call                |

## AI

| Component                           | Role                                                     |
| ----------------------------------- | -------------------------------------------------------- |
| [Ollama](./ollama.md)               | Local language models                                    |
| [AI services](./ai-services.md)     | Models, OCR and transcription configuration for all apps |
| [Conversations](./conversations.md) | AI assistant over your own documents                     |
| [Dictaphone](./dictaphone.md)       | Transcription and meeting summaries, with export to Docs |

## Platform services

| Component             | Role                                    |
| --------------------- | --------------------------------------- |
| [ClamAV](./clamav.md) | Antivirus scanning for uploads and mail |

## Adding a component

New components follow the patterns in
[Development](../development/index.md): a chart, values wired through the default
environment, policies and tests. See
[Add a new component](../development/add-component.md).
