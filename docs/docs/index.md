---
sidebar_position: 10
---

# Introduction

MijnBureau is a cloud-native digital workplace suite. Its primary goal is to provide an **autonomous** solution, ensuring you can run everything on your own hardware - including Red Hat OpenShift - while maintaining full control over your critical data.

Developed in collaboration with Dutch municipalities, provinces, and ministries, MijnBureau draws inspiration and collaborates with similar initiatives like Germany’s Opendesk and France’s LaSuite.

Although MijnBureau is a public-driven initiative, its licensing encourages private sector actors to use, sell, and contribute to the project.

## How to read these docs

The documentation is organised by what you are trying to do:

| If you want to...                                   | Start here                                                                |
| --------------------------------------------------- | ------------------------------------------------------------------------- |
| Understand what MijnBureau is and whether it fits   | This page                                                                 |
| Install it on a cluster                             | [Getting started](./getting_started/index.md)                             |
| Use an application (chat, mail, files, meetings)    | [Using MijnBureau](./user-guide/index.md)                                 |
| Deploy, configure or upgrade it                     | [Components](./components/index.md) and [Operating](./operating/index.md) |
| Run it day to day: access, backups, DNS, monitoring | [Operating](./operating/index.md)                                         |
| Meet security and compliance requirements           | [Security](./security/index.md)                                           |
| Understand why it is built this way                 | [Architecture](./architecture/index.md)                                   |
| Contribute code or a new component                  | [Development](./development/index.md)                                     |

Each application appears in two places on purpose: **Components** describes how
it is deployed and configured, and **Using MijnBureau** how to work with it.

---

## What you get

MijnBureau gives you one workspace for seamless collaboration and communication across teams and organizations.

### Work together

| Capability   | What it gives you                            | How to use it                          |
| ------------ | -------------------------------------------- | -------------------------------------- |
| Documents    | Collaborative documents, wikis and notes     | [Docs](./user-guide/docs.md)           |
| Office files | In-browser editing of Word, Excel and slides | [Collabora](./user-guide/collabora.md) |
| File sharing | Shared drives, links and permissions         | [Drive](./user-guide/drive.md)         |
| Projects     | Plans, pages and tasks per team              | [Projects](./user-guide/projects.md)   |
| Calendar     | Shared calendars, invitations and CalDAV     | [Calendar](./user-guide/calendars.md)  |

### Communicate

| Capability         | What it gives you                                         | How to use it                        |
| ------------------ | --------------------------------------------------------- | ------------------------------------ |
| Chat               | Channels and direct messages over Matrix, with federation | [Element](./user-guide/element.md)   |
| Email              | Shared inboxes, threads and mail domains                  | [Messages](./user-guide/messages.md) |
| Video conferencing | Meetings with screen sharing, recording and summaries     | [Meet](./user-guide/meet.md)         |

### Find everything

| Capability | What it gives you                      | How to use it                        |
| ---------- | -------------------------------------- | ------------------------------------ |
| Search     | One search across documents and files  | [Find](./user-guide/find.md)         |
| Contacts   | Shared address books and people lookup | [Contacts](./user-guide/contacts.md) |

### AI

| Capability    | What it gives you                     | How to use it                                  |
| ------------- | ------------------------------------- | ---------------------------------------------- |
| AI assistant  | Ask questions over your own documents | [Conversations](./user-guide/conversations.md) |
| Transcription | Meeting transcripts and summaries     | [Dictaphone](./user-guide/dictaphone.md)       |

### Organise work

| Capability | What it gives you                                   | How to use it                            |
| ---------- | --------------------------------------------------- | ---------------------------------------- |
| Bureaublad | One start page for all tools and the team directory | [Bureaublad](./user-guide/bureaublad.md) |

Looking for instructions per tool? [Using MijnBureau](./user-guide/index.md)
explains how to sign in and how to work with every application, from chat and
mail to documents, meetings and search.

---

## Main Components

MijnBureau currently includes the following key components:

| Feature            | Functional Component | Component Version                                                               | Upstream Documentation                                                               | LICENSE    |
| ------------------ | -------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ---------- |
| Identity Provider  | Keycloak             | [26.8.2](https://github.com/keycloak/keycloak/releases/tag/26.8.2)              | [documentation](https://www.keycloak.org/documentation)                              | Apache-2.0 |
| Chat               | Element Synapse      | [v1.166.0](https://github.com/element-hq/synapse/releases/tag/v1.166.0)         | [documentation](https://element-hq.github.io/synapse/latest/)                        | AGPL-3.0   |
| Chat UI            | Element Web          | [v1.12.36](https://github.com/element-hq/element-web/releases/tag/v1.12.36)     | [documentation](https://element.io/)                                                 | AGPL-3.0   |
| Chat Auth          | MAS                  | [1.30.0](https://github.com/element-hq/matrix-authentication-service/)          | [documentation](https://element-hq.github.io/matrix-authentication-service/)         | Apache-2.0 |
| AI LLM             | Ollama               | [v0.40.19](https://github.com/ollama/ollama/tree/v0.40.19)                      | [documentation](https://ollama.com/)                                                 | MIT        |
| File sharing       | Nextcloud            | [v35.0.3](https://github.com/nextcloud/server/tree/v35.0.3)                     | [documentation](https://nextcloud.com/)                                              | AGPL-3.0   |
| Project Management | Projects             | [1.27.13](https://hub.docker.com/r/lasuite/projects/tags)                       | [documentation](https://github.com/suitenumerique/projects/blob/main/README.md)      | AGPL-3.0   |
| Contacts           | Contacts             | [main](https://github.com/suitenumerique/contacts)                              | [documentation](https://github.com/suitenumerique/contacts/tree/main/docs)           | MIT        |
| Search             | Find                 | [main](https://github.com/suitenumerique/find)                                  | [documentation](https://github.com/suitenumerique/find)                              | MIT        |
| Calendar           | Calendars            | [v0.2.0](https://github.com/suitenumerique/calendars/releases/tag/v0.2.0)       | [documentation](https://github.com/suitenumerique/calendars/tree/main/docs)          | MIT        |
| Transcription      | Dictaphone           | [v0.17.2](https://github.com/suitenumerique/dictaphone/releases/tag/v0.17.2)    | [documentation](https://github.com/suitenumerique/dictaphone)                        | MIT        |
| Email              | Messages             | [v0.10.0](https://github.com/suitenumerique/messages/releases/tag/v0.10.0)      | [documentation](https://github.com/suitenumerique/messages/tree/main/docs)           | MIT        |
| Notes              | Docs                 | [v6.1.1](https://github.com/suitenumerique/docs/releases/tag/v6.1.1)            | [documentation](https://github.com/suitenumerique/docs/tree/main/docs/installation)  | MIT        |
| Office             | Collabora            | [26.04.6.2.1](https://hub.docker.com/r/collabora/code/tags)                     | [documentation](https://sdk.collaboraonline.com/docs/installation/index.html)        | MPL-2.0    |
| Video backend      | Livekit              | [v1.13.11](https://github.com/livekit/livekit/releases/tag/v1.13.11)            | [documentation](https://livekit.io/)                                                 | Apache-2.0 |
| AI Assistent       | Conversations        | [v0.0.29](https://github.com/suitenumerique/conversations/releases/tag/v0.0.29) | [documentation](https://github.com/suitenumerique/conversations/blob/main/README.md) | MIT        |
| Video conferencing | Meet                 | [v1.38.0](https://github.com/suitenumerique/meet/releases/tag/v1.38.0)          | [documentation](https://github.com/suitenumerique/meet/tree/main/docs)               | MIT        |
| Bureaublad         | Startpage            | [v2.1.0](https://github.com/MinBZK/bureaublad)                                  | [documentation](https://github.com/MinBZK/bureaublad)                                | EUPL-1.2   |
| File sharing       | Drive                | [v1.1.1](https://github.com/suitenumerique/drive/releases/tag/v1.1.1)           | [documentation](https://github.com/suitenumerique/drive/blob/main/README.md)         | MIT        |
| Token Exchange     | Menshen              | [v0.7.0](https://github.com/suitenumerique/menshen/releases/tag/v0.7.0)         | [documentation](https://github.com/suitenumerique/menshen)                           | MIT        |
| Antivirus Toolkit  | ClamAV               | [v1.5.5](https://github.com/Cisco-Talos/clamav/releases/tag/clamav-1.5.5)       | [documentation](https://docs.clamav.net/)                                            | GPLv2      |

The demo environment also deploys the supporting datastores below. Production
environments are expected to supply equivalent external services; see
[Installation](getting_started/installation.md).

| Role           | Component         | Version                                                          | Upstream Documentation                                       | LICENSE      |
| -------------- | ----------------- | ---------------------------------------------------------------- | ------------------------------------------------------------ | ------------ |
| Database       | PostgreSQL (CNPG) | [17.12](https://github.com/cloudnative-pg/postgresql)            | [documentation](https://cloudnative-pg.io/documentation/)    | PostgreSQL   |
| Cache / broker | Valkey            | [9.2.1](https://github.com/valkey-io/valkey/releases/tag/9.2.1)  | [documentation](https://valkey.io/docs/)                     | BSD-3-Clause |
| Object storage | SeaweedFS         | [4.55](https://github.com/seaweedfs/seaweedfs/releases/tag/4.55) | [documentation](https://github.com/seaweedfs/seaweedfs/wiki) | Apache-2.0   |

## Where to go next

- [Getting started](./getting_started/index.md) - install it on a cluster.
- [Using MijnBureau](./user-guide/index.md) - sign in and use the applications.
- [Operating](./operating/index.md) - administration, secrets, backups, DNS and
  monitoring.
- [Security](./security/index.md) - tenancy, identity federation and supply
  chain.

Questions, or want to compare notes with other deployments? Join the
[Matrix room](https://matrix.to/#/#mijnbureau:matrix.org) or mail
[mijnbureau@rijksoverheid.nl](mailto:mijnbureau@rijksoverheid.nl).
