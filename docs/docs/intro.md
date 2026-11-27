---
sidebar_position: 1
---

# Introduction

MijnBureau is an digital workplace suite. Its primary goal is to provide an **autonomous** solution, ensuring you can run everything on your own hardware while maintaining full control over your critical data.

Developed in collaboration with Dutch municipalities, provinces, and ministries, MijnBureau draws inspiration and collaborates with similar initiatives like Germany’s Opendesk and France’s LaSuite.

Although MijnBureau is a public-driven initiative, its licensing encourages private sector actors to use, sell, and contribute to the project.

---

## Features

MijnBureau gives you one workspace for seamless collaboration and communication across teams and organizations.

- **Work together:** documents, spreadsheets, presentations, notes, project management, calendars and secure file sharing.
- **Communicate:** team chat, video conferencing and email
- **Find everything:** one search across documents and files.
- **AI:** AI-assisted workflows, including meeting summaries and transcription.
- **Organize work:** one start page for all tools and a shared team directory.
- **Manage access:** integrated identity management, user portal, and admin portals.

Looking for instructions per tool? The [User guide](./user-guide/index.md) explains
how to sign in and how to work with every application, from chat and mail to
documents, meetings and search.

---

## Main Components

MijnBureau currently includes the following key components:

| Feature            | Functional Component | Component Version                                                               | Upstream Documentation                                                               | LICENSE    |
| ------------------ | -------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ---------- |
| Identity Provider  | Keycloak             | [26.8.2](https://github.com/keycloak/keycloak/releases/tag/26.8.2)              | [documentation](https://www.keycloak.org/documentation)                              | Apache-2.0 |
| Chat               | Element Synapse      | [v1.165.0](https://github.com/element-hq/synapse/releases/tag/v1.165.0)         | [documentation](https://element-hq.github.io/synapse/latest/)                        | AGPL-3.0   |
| Chat UI            | Element Web          | [v1.12.35](https://github.com/element-hq/element-web/releases/tag/v1.12.35)     | [documentation](https://element.io/)                                                 | AGPL-3.0   |
| Chat Auth          | MAS                  | [1.29.0](https://github.com/element-hq/matrix-authentication-service/)          | [documentation](https://element-hq.github.io/matrix-authentication-service/)         | Apache-2.0 |
| AI LLM             | Ollama               | [v0.40.16](https://github.com/ollama/ollama/tree/v0.40.16)                      | [documentation](https://ollama.com/)                                                 | MIT        |
| File sharing       | Nextcloud            | [v35.0.3](https://github.com/nextcloud/server/tree/v35.0.3)                     | [documentation](https://nextcloud.com/)                                              | AGPL-3.0   |
| Project Management | Projects             | [1.27.13](https://hub.docker.com/r/lasuite/projects/tags)                       | [documentation](https://github.com/suitenumerique/projects/blob/main/README.md)      | AGPL-3.0   |
| Search             | Find                 | [main](https://github.com/suitenumerique/find)                                  | [documentation](https://github.com/suitenumerique/find)                              | MIT        |
| Teams & Contacts   | People               | [v1.27.1](https://github.com/suitenumerique/people/releases/tag/v1.27.1)        | [documentation](https://github.com/suitenumerique/people/tree/main/docs)             | MIT        |
| Calendar           | Calendars            | [v0.2.0](https://github.com/suitenumerique/calendars/releases/tag/v0.2.0)       | [documentation](https://github.com/suitenumerique/calendars/tree/main/docs)          | MIT        |
| Transcription      | Dictaphone           | [v0.16.1](https://github.com/suitenumerique/dictaphone/releases/tag/v0.16.1)    | [documentation](https://github.com/suitenumerique/dictaphone)                        | MIT        |
| Email              | Messages             | [main](https://github.com/suitenumerique/messages)                              | [documentation](https://github.com/suitenumerique/messages/tree/main/docs)           | MIT        |
| Notes              | Docs                 | [v6.1.1](https://github.com/suitenumerique/docs/releases/tag/v6.1.1)            | [documentation](https://github.com/suitenumerique/docs/tree/main/docs/installation)  | MIT        |
| Office             | Collabora            | [26.04.6.1.1](https://hub.docker.com/r/collabora/code/tags)                     | [documentation](https://sdk.collaboraonline.com/docs/installation/index.html)        | MPL-2.0    |
| Video backend      | Livekit              | [v1.13.11](https://github.com/livekit/livekit/releases/tag/v1.13.11)            | [documentation](https://livekit.io/)                                                 | Apache-2.0 |
| AI Assistent       | Conversations        | [v0.0.29](https://github.com/suitenumerique/conversations/releases/tag/v0.0.29) | [documentation](https://github.com/suitenumerique/conversations/blob/main/README.md) | MIT        |
| Video conferencing | Meet                 | [v1.37.0](https://github.com/suitenumerique/meet/releases/tag/v1.37.0)          | [documentation](https://github.com/suitenumerique/meet/tree/main/docs)               | MIT        |
| Bureaublad         | Startpage            | [v2.1.0](https://github.com/MinBZK/bureaublad)                                  | [documentation](https://github.com/MinBZK/bureaublad)                                | EUPL-1.2   |
| File sharing       | Drive                | [v1.0.0](https://github.com/suitenumerique/drive/releases/tag/v1.0.0)           | [documentation](https://github.com/suitenumerique/drive/blob/main/README.md)         | MIT        |
| Token Exchange     | Menshen              | [v0.6.0](https://github.com/suitenumerique/menshen/releases/tag/v0.6.0)         | [documentation](https://github.com/suitenumerique/menshen)                           | MIT        |
| Antivirus Toolkit  | ClamAV               | [v1.5.4](https://github.com/Cisco-Talos/clamav/releases/tag/clamav-1.5.4)       | [documentation](https://docs.clamav.net/)                                            | GPLv2      |

The demo environment also deploys the supporting datastores below. Production
environments are expected to supply equivalent external services; see
[Setup](./getting_started/setup.md).

| Role           | Component         | Version                                                                               | Upstream Documentation                                          | LICENSE      |
| -------------- | ----------------- | ------------------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| Database       | PostgreSQL (CNPG) | [17.12](https://github.com/cloudnative-pg/postgresql)                                 | [documentation](https://cloudnative-pg.io/documentation/)       | PostgreSQL   |
| Cache / broker | Valkey            | [9.1.3](https://github.com/valkey-io/valkey/releases/tag/9.1.3)                       | [documentation](https://valkey.io/docs/)                        | BSD-3-Clause |
| Object storage | MinIO             | [2025.7.23](https://github.com/minio/minio/releases/tag/RELEASE.2025-07-23T15-54-02Z) | [documentation](https://min.io/docs/minio/kubernetes/upstream/) | AGPL-3.0     |
