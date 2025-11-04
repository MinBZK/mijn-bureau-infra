---
sidebar_position: 1
---

# Introduction

MijnBureau is a flexible and secure digital workplace suite. Its primary goal is to provide an **autonomous** solution for digital workplaces, ensuring you can run everything on your own hardware while maintaining full control over your critical data.

Developed in collaboration with Dutch municipalities, provinces, and ministries, MijnBureau draws inspiration from similar initiatives like Germany’s Opendesk and France’s LaSuite.

Although MijnBureau is a public-driven initiative, its licensing encourages private sector actors to use, sell, and contribute to the project.

---

## Features

MijnBureau offers a rich set of features focused on collaboration:

- Collaborative Documents
- Collaborative Spreadsheets
- Collaborative Presentations
- Collaborative Notes
- Secure File Sharing
- Team Chat
- Self-hosted AI Language Models
- Integrated Identity Management
- Video Conferencing
- AI Assistant
- Start page with integrations to the different features

### Planned Features

We are actively expanding the suite with plans to include:

- Discussion Forum
- Password Manager
- Email
- User Portal
- Admin Portal

---

## Main Components

MijnBureau currently includes the following key components:

| Feature            | Functional Component | Component Version                                                                 | Upstream Documentation                                                               | LICENSE    |
| ------------------ | -------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ---------- |
| Identity Provider  | Keycloak             | [26.3.3](https://github.com/keycloak/keycloak/releases/tag/26.3.3)                | [documentation](https://www.keycloak.org/documentation)                              | Apache-2.0 |
| Chat               | Element Synapse      | [v1.129](https://github.com/element-hq/synapse/tree/v1.129.0)                     | [documentation](https://element-hq.github.io/synapse/latest/)                        | AGPL-3.0   |
| Chat UI            | Element Web          | [V1.11.106](https://github.com/element-hq/element-web/tree/v1.11.106)             | [documentation](https://element.io/)                                                 | AGPL-3.0   |
| AI LLM             | Ollama               | [v0.7.0](https://github.com/ollama/ollama/tree/v0.7.0)                            | [documentation](https://ollama.com/)                                                 | MIT        |
| Spreadsheet        | Grist                | [v1.6.1](https://github.com/gristlabs/grist-core/tree/v1.6.1)                     | [documentation](https://support.getgrist.com/self-managed/)                          | Apache-2.0 |
| File sharing       | Nextcloud            | [v30.0.7](https://github.com/nextcloud/server/tree/v30.0.7)                       | [documentation](https://nextcloud.com/)                                              | AGPL-3.0   |
| Office             | Collabora            | [v25.04.5.1](https://github.com/CollaboraOnline/online/releases/tag/cp-25.04.5-1) | [documentation](https://sdk.collaboraonline.com/docs/installation/index.html)        | MPL-2.0    |
| Notes              | Docs                 | [v3.8.21](https://github.com/suitenumerique/docs/releases/tag/v3.8.21)            | [documentation](https://github.com/suitenumerique/docs/tree/main/docs/installation)  | MIT        |
| Video backend      | Livekit              | [v1.9.3](https://github.com/livekit/livekit/releases/tag/v1.9.3)                  | [documentation](https://livekit.io/)                                                 | Apache-2.0 |
| Video conferencing | Meet                 | [v0.1.38](https://github.com/suitenumerique/meet/releases/tag/v0.1.38)            | [documentation](https://github.com/suitenumerique/meet/tree/main/docs)               | MIT        |
| AI Assistent       | Conversations        | [v0.0.5](https://github.com/suitenumerique/conversations/tags/v0.0.5)             | [documentation](https://github.com/suitenumerique/conversations/blob/main/README.md) | MIT        |
| Bureaublad         | Startpage            | [v0.1.0](https://github.com/MinBZK/bureaublad/releases/tag/v0.1.0)                | [documentation](https://github.com/MinBZK/bureaublad)                                | EUPL-1.2   |
