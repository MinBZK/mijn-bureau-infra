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
- **AI** AI-assisted workflows
- **Organize work:** one start page for all tools.
- **Manage access:** integrated identity management, user portal, and admin portal.

### Planned Features

We are actively expanding the suite with plans to include:

- Password Manager

---

## Main Components

MijnBureau currently includes the following key components:

| Feature            | Functional Component | Component Version                                                               | Upstream Documentation                                                               | LICENSE    |
| ------------------ | -------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ---------- |
| Identity Provider  | Keycloak             | [26.8.1](https://github.com/keycloak/keycloak/releases/tag/26.8.1)              | [documentation](https://www.keycloak.org/documentation)                              | Apache-2.0 |
| Chat               | Element Synapse      | [v1.164.1](https://github.com/element-hq/synapse/releases/tag/v1.164.1)         | [documentation](https://element-hq.github.io/synapse/latest/)                        | AGPL-3.0   |
| Chat UI            | Element Web          | [v1.12.33](https://github.com/element-hq/element-web/releases/tag/v1.12.33)     | [documentation](https://element.io/)                                                 | AGPL-3.0   |
| Chat Auth          | MAS                  | [1.29.0](https://github.com/element-hq/matrix-authentication-service/)          | [documentation](https://element-hq.github.io/matrix-authentication-service/)         | Apache-2.0 |
| AI LLM             | Ollama               | [v0.40.14](https://github.com/ollama/ollama/tree/v0.40.14)                      | [documentation](https://ollama.com/)                                                 | MIT        |
| File sharing       | Nextcloud            | [v35.0.2](https://github.com/nextcloud/server/tree/v35.0.2)                     | [documentation](https://nextcloud.com/)                                              | AGPL-3.0   |
| Project Management | Projects             | [1.27.13](https://hub.docker.com/r/lasuite/projects/tags)                       | [documentation](https://github.com/suitenumerique/projects/blob/main/README.md)      | AGPL-3.0   |
| Calendar           | Calendars            | [main](https://github.com/suitenumerique/calendars)                             | [documentation](https://github.com/suitenumerique/calendars/tree/main/docs)          | MIT        |
| Transcription      | Dictaphone           | [v0.15.4](https://github.com/suitenumerique/dictaphone/releases/tag/v0.15.4)    | [documentation](https://github.com/suitenumerique/dictaphone)                        | MIT        |
| Email              | Messages             | [main](https://github.com/suitenumerique/messages)                              | [documentation](https://github.com/suitenumerique/messages/tree/main/docs)           | MIT        |
| Notes              | Docs                 | [v5.7.0](https://github.com/suitenumerique/docs/releases/tag/v5.7.0)            | [documentation](https://github.com/suitenumerique/docs/tree/main/docs/installation)  | MIT        |
| Office             | Collabora            | [26.04.5.1.1](https://hub.docker.com/r/collabora/code/tags)                     | [documentation](https://sdk.collaboraonline.com/docs/installation/index.html)        | MPL-2.0    |
| Video backend      | Livekit              | [v1.13.11](https://github.com/livekit/livekit/releases/tag/v1.13.11)            | [documentation](https://livekit.io/)                                                 | Apache-2.0 |
| AI Assistent       | Conversations        | [v0.0.28](https://github.com/suitenumerique/conversations/releases/tag/v0.0.28) | [documentation](https://github.com/suitenumerique/conversations/blob/main/README.md) | MIT        |
| Video conferencing | Meet                 | [v1.37.0](https://github.com/suitenumerique/meet/releases/tag/v1.37.0)          | [documentation](https://github.com/suitenumerique/meet/tree/main/docs)               | MIT        |
| Bureaublad         | Startpage            | [v2.0.1](https://github.com/MinBZK/bureaublad)                                  | [documentation](https://github.com/MinBZK/bureaublad)                                | EUPL-1.2   |
| File sharing       | Drive                | [v0.26.0](https://github.com/suitenumerique/drive/releases/tag/v0.26.0)         | [documentation](https://github.com/suitenumerique/drive/blob/main/README.md)         | MIT        |
| Antivirus Toolkit  | ClamAV               | [v1.5.4](https://github.com/Cisco-Talos/clamav/releases/tag/clamav-1.5.4)       | [documentation](https://docs.clamav.net/)                                            | GPLv2      |
