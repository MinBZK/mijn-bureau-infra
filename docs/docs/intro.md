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

- **Work together:** documents, spreadsheets, presentations, notes, project management and secure file sharing.
- **Communicate:** team chat, video conferencing
- **AI** AI-assisted workflows
- **Organize work:** one start page for all tools.
- **Manage access:** integrated identity management, user portal, and admin portal.

### Planned Features

We are actively expanding the suite with plans to include:

- Email
- Agenda
- Password Manager

---

## Main Components

MijnBureau currently includes the following key components:

| Feature            | Functional Component | Component Version                                                                   | Upstream Documentation                                                               | LICENSE    |
| ------------------ | -------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ---------- |
| Identity Provider  | Keycloak             | [26.3.3](https://github.com/keycloak/keycloak/releases/tag/26.3.3)                  | [documentation](https://www.keycloak.org/documentation)                              | Apache-2.0 |
| Chat               | Element Synapse      | [v1.154.0](https://github.com/element-hq/synapse/releases/tag/v1.154.0)             | [documentation](https://element-hq.github.io/synapse/latest/)                        | AGPL-3.0   |
| Chat UI            | Element Web          | [v1.12.20](https://github.com/element-hq/element-web/releases/tag/v1.12.20)         | [documentation](https://element.io/)                                                 | AGPL-3.0   |
| AI LLM             | Ollama               | [v0.30.6](https://github.com/ollama/ollama/tree/v0.30.6)                            | [documentation](https://ollama.com/)                                                 | MIT        |
| File sharing       | Nextcloud            | [v33.0.5](https://github.com/nextcloud/server/tree/v33.0.5)                         | [documentation](https://nextcloud.com/)                                              | AGPL-3.0   |
| Spreadsheet        | Grist                | [v1.7.14](https://github.com/gristlabs/grist-core/tree/v1.7.14)                     | [documentation](https://support.getgrist.com/self-managed/)                          | Apache-2.0 |
| Project Management | OpenProject          | [v16.6.3](https://github.com/MinBZK/mijn-bureau-opf/releases/tag/v16.6.3)           | [documentation](https://www.openproject.org/docs/)                                   | GPL-3.0    |
| Notes              | Docs                 | [v5.2.1](https://github.com/suitenumerique/docs/releases/tag/v5.2.1)                | [documentation](https://github.com/suitenumerique/docs/tree/main/docs/installation)  | MIT        |
| Office             | Collabora            | [v25.04.9.4.1](https://github.com/CollaboraOnline/online/releases/tag/cp-25.04.9-4) | [documentation](https://sdk.collaboraonline.com/docs/installation/index.html)        | MPL-2.0    |
| Video backend      | Livekit              | [v1.12.0](https://github.com/livekit/livekit/releases/tag/v1.12.0)                  | [documentation](https://livekit.io/)                                                 | Apache-2.0 |
| AI Assistent       | Conversations        | [v0.0.17](https://github.com/suitenumerique/conversations/releases/tag/v0.0.17)     | [documentation](https://github.com/suitenumerique/conversations/blob/main/README.md) | MIT        |
| Video conferencing | Meet                 | [v1.19.0](https://github.com/suitenumerique/meet/releases/tag/v1.19.0)              | [documentation](https://github.com/suitenumerique/meet/tree/main/docs)               | MIT        |
| Bureaublad         | Startpage            | [v0.9.3](https://github.com/MinBZK/bureaublad/releases/tag/v0.9.3)                  | [documentation](https://github.com/MinBZK/bureaublad)                                | EUPL-1.2   |
| File sharing       | Drive                | [v0.18.0](https://github.com/suitenumerique/drive/releases/tag/v0.18.0)             | [documentation](https://github.com/suitenumerique/drive/blob/main/README.md)         | MIT        |
| Antivirus Toolkit  | ClamAV               | [v1.5.2](https://github.com/Cisco-Talos/clamav/releases/tag/clamav-1.5.2)           | [documentation](https://docs.clamav.net/)                                            | GPLv2      |
