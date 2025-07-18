---
sidebar_position: 1
---

# MijnBureau: Open Source Digital Workplace

MijnBureau is a Kubernetes-based, open-source, and cloud-native digital workplace suite. It is designed to replace functional components with your own hosted solution like the identity management and portal which often already exist in organisations.

MijnBureau currently features the following main components:

| Function          | Functional Component | Component Version                                                  | Upstream Documentation                                        | LICENSE    |
| ----------------- | -------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------- | ---------- |
| Identity Provider | Keycloak             | [26.2.4](https://github.com/keycloak/keycloak/releases/tag/26.2.4) | [documentation](https://www.keycloak.org/documentation)       | Apache-2.0 |
| Chat              | Element synapse      | [v1.129](https://github.com/element-hq/synapse/tree/v1.129.0)      | [documentation](https://element-hq.github.io/synapse/latest/) | AGPL-3.0   |
| Notes             | Docs                 | [v3.2.1](https://github.com/suitenumerique/docs/tree/v3.2.1)       |                                                               | MIT        |
| AI LLM            | Ollama               | [v0.7.0](https://github.com/ollama/ollama/tree/v0.7.0)             | [documentation](https://ollama.com/)                          | MIT        |
| Spreadsheet       | Grist                | [v1.6.1](https://github.com/gristlabs/grist-core/tree/v1.6.1)      | [documentation](https://support.getgrist.com/self-managed/)   | Apache-2.0 |
