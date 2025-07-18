# Mijn Bureau deployment automation

`MijnBureau` is a collaboration suite. This repo is the deployment automation for MijnBureau.

> [!IMPORTANT]
> This is still a prototype

## Overview

MijnBureau is a Kubernetes-based, open-source, and cloud-native digital workplace suite. It is designed to replace functional components with your own hosted solution like the identity management and portal which often already exist in organisations.

MijnBureau currently features the following main components:

| Function          | Functional Component | Component Version                                                  | Upstream Documentation                                        | LICENSE    |
| ----------------- | -------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------- | ---------- |
| Identity Provider | Keycloak             | [26.2.4](https://github.com/keycloak/keycloak/releases/tag/26.2.4) | [documentation](https://www.keycloak.org/documentation)       | Apache-2.0 |
| Chat              | Element synapse      | [v1.133](https://github.com/element-hq/synapse/tree/v1.133.0)      | [documentation](https://element-hq.github.io/synapse/latest/) | AGPL-3.0   |
| Notes             | Docs                 | [v3.2.1](https://github.com/suitenumerique/docs/tree/v3.2.1)       |                                                               | MIT        |
| AI LLM            | Ollama               | [v0.7.0](https://github.com/ollama/ollama/tree/v0.7.0)             | [documentation](https://ollama.com/)                          | MIT        |
| Spreadsheet       | Grist                | [v1.6.1](https://github.com/gristlabs/grist-core/tree/v1.6.1)      | [documentation](https://support.getgrist.com/self-managed/)   | Apache-2.0 |

## Requirements

MijnBureau is a Kubernetes-only solution and requires an existing Kubernetes (K8s) cluster. You also need a domain.

## Getting started

We use [Helmfile](https://helmfile.readthedocs.io/en/latest/) to generate all Kubernetes manifests. Before you can generate the manifests, you need to install [Helm](https://helm.sh/) and [helm-secrets](https://github.com/jkroepke/helm-secret). The Helmfile entrypoint is the [helmfile.yaml](helmfile.yaml).

To generate all manifests, use the following command in the base directory:

```bash
export MIJNBUREAU_MASTER_PASSWORD=changethis
helmfile template
```

## Commit rules

We use the [gitmoji](https://gitmoji.dev/) commit convention with the following scopes: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

## Mijn Bureau

For more detailed information, see the [MijnBureau docs](https://minbzk.github.io/mijn-bureau/).

This project is a sub-project of MijnBureau and it is part of the same governance. See:

- [Governance](https://github.com/MinBZK/mijn-bureau/blob/main/GOVERNANCE.md) (Dutch)
- [Code of conduct](https://github.com/MinBZK/mijn-bureau/blob/main/CODE_OF_CONDUCT.md) (Dutch)
- [Contributing](https://github.com/MinBZK/mijn-bureau/blob/main/CONTRIBUTING.md) (Dutch)
- [Security](https://github.com/MinBZK/mijn-bureau/blob/main/SECURITY.md) (Dutch)

---

Licensed under the EUPL-1.2 license.
[EUPL (Public License of the European Union 1.2 or higher)](LICENSE)

Copyright: The State of the Netherlands and all contributors
