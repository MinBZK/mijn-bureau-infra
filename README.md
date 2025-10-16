# MijnBureau

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/minbzk/mijn-bureau-infra/ci.yaml)
![GitHub License](https://img.shields.io/github/license/minbzk/mijn-bureau-infra)

`MijnBureau` is a collaboration suite built for civil servants. It provides a flexible and secure digital workplace with a strong focus on autonomy. The tool includes features such as collaborative document editing, file sharing, chat, video conferencing, and many other tools to support effective teamwork.

## Overview

MijnBureau is a flexible and secure digital workplace suite. Its main goal is to provide an **autonomous** solution for digital workplaces, ensuring you can run everything on your own hardware and maintain full control over your critical data.

MijnBureau is developed in collaboration with Dutch municipalities, provinces, and ministries, inspired by similar initiatives such as Germany’s Opendesk and France’s LaSuite.

While MijnBureau is a public-driven initiative, our license choice is an invitation for private sector actors to use, sell and contribute to the project.

Go to the [Documentation](https://minbzk.github.io/mijn-bureau-infra/) to learn more.

## Why use MijnBureau

### Easy to install

MijnBureau is simple to deploy and provides a comprehensive set of tools your employees need, from collaborative document editing and chat to video conferencing.

### Secure & Sovereign

Security and data sovereignty are at the heart of MijnBureau. By running on your own infrastructure, you stay in full control of your data, ensuring compliance. The platform is built with strong architecture, automated policies, and continuous security scanning.

### Flexible

MijnBureau adapts to your organization’s needs. You can enable only the features you require and seamlessly integrate with existing systems, such as identity management or document editing tools. This flexibility ensures you can modernize your digital workplace without losing control over your data.

## Getting started

Go to the [Documentation](https://minbzk.github.io/mijn-bureau-infra/) to get started

## Features

MijnBureau already offers a rich set of features, with a strong focus on collaboration:

- Collaborative Documents
- Collaborative Spreadsheet
- Collaborative Presentations
- Secure file sharing
- Team chat
- Self-hosted AI language models
- Integrated identity management

We are actively expanding the suite and plan to add even more capabilities, including:

- AI Assistant
- Discussion forum
- Video conferencing
- Password manager
- Email
- User Portal
- Admin Portal

## Commit Conventions

This repo uses the [gitmoji](https://gitmoji.dev/) commit convention with the following scopes:

1. folder names in helmfile/apps/\* (the products)
2. settings: update settings (not related to 1 product)
3. deps: update dependencies (not related to 1 product)
4. docs: documentation update (not related to 1 product)
5. tests: general tests (not related to 1 product)
6. policies: general policies (not related to 1 product)
7. ci: general CI updates
8. other: If none of the above apply

## Additional Resources

This repo is the technical implementation of [MijnBureau](https://github.com/MinBZK/mijn-bureau) and it is part of the same governance. See:

- [Governance](https://github.com/MinBZK/mijn-bureau/blob/main/GOVERNANCE.md) (Dutch)
- [Code of conduct](https://github.com/MinBZK/mijn-bureau/blob/main/CODE_OF_CONDUCT.md) (Dutch)
- [Contributing](https://github.com/MinBZK/mijn-bureau/blob/main/CONTRIBUTING.md) (Dutch)
- [Security](https://github.com/MinBZK/mijn-bureau/blob/main/SECURITY.md) (Dutch)

## Credits ❤️

MijnBureau is built on top of some impressive open-source tools.

It currently includes the following open-source components

| Feature            | Functional Component | Component Version                                                                 | Upstream Documentation                                                               | LICENSE    |
| ------------------ | -------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ---------- |
| Identity Provider  | Keycloak             | [26.2.4](https://github.com/keycloak/keycloak/releases/tag/26.2.4)                | [documentation](https://www.keycloak.org/documentation)                              | Apache-2.0 |
| Chat               | Element Synapse      | [v1.129](https://github.com/element-hq/synapse/tree/v1.129.0)                     | [documentation](https://element-hq.github.io/synapse/latest/)                        | AGPL-3.0   |
| Chat UI            | Element Web          | [V1.11.106](https://github.com/element-hq/element-web/tree/v1.11.106)             | [documentation](https://element.io/)                                                 | AGPL-3.0   |
| AI LLM             | Ollama               | [v0.7.0](https://github.com/ollama/ollama/tree/v0.7.0)                            | [documentation](https://ollama.com/)                                                 | MIT        |
| Spreadsheet        | Grist                | [v1.6.1](https://github.com/gristlabs/grist-core/tree/v1.6.1)                     | [documentation](https://support.getgrist.com/self-managed/)                          | Apache-2.0 |
| File sharing       | Nextcloud            | [v30.0.7](https://github.com/nextcloud/server/tree/v30.0.7)                       | [documentation](https://nextcloud.com/)                                              | AGPL-3.0   |
| Office             | Collabora            | [v25.04.5.1](https://github.com/CollaboraOnline/online/releases/tag/cp-25.04.5-1) | [documentation](https://sdk.collaboraonline.com/docs/installation/index.html)        | MPL-2.0    |
| Notes              | Docs                 | [v3.8.0](https://github.com/suitenumerique/docs/releases/tag/v3.8.0)              | [documentation](https://github.com/suitenumerique/docs/tree/main/docs/installation)  | MIT        |
| Video backend      | Livekit              | [v1.9.1](https://github.com/livekit/livekit/releases/tag/v1.9.1)                  | [documentation](https://livekit.io/)                                                 | Apache-2.0 |
| Video conferencing | meet                 | [v0.1.38](https://github.com/suitenumerique/meet/releases/tag/v0.1.38)            | [documentation](https://github.com/suitenumerique/meet/tree/main/docs)               | MIT        |
| AI Assistent       | Conversations        | [main](https://github.com/suitenumerique/conversations/)                          | [documentation](https://github.com/suitenumerique/conversations/blob/main/README.md) | MIT        |

---

Licensed under the EUPL-1.2 license.
[EUPL (Public License of the European Union 1.2 or higher)](LICENSE)

Copyright: The State of the Netherlands and all contributors
