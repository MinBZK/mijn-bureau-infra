# MijnBureau deployment automation

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/minbzk/mijn-bureau-infra/ci.yaml)
![GitHub License](https://img.shields.io/github/license/minbzk/mijn-bureau-infra)

`MijnBureau` is a collaboration suite for civil servants. This repository contains the deployment automation scripts and configuration for setting up MijnBureau using Kubernetes and Helm.

> [!IMPORTANT]
> This project is currently a prototype and under active development

## Overview

MijnBureau is a Kubernetes-native, cloud-first, and open-source digital workplace suite designed to be flexible, secure, and modular.

It currently includes the following components:

| Function          | Functional Component | Component Version                                                  | Upstream Documentation                                        | LICENSE    |
| ----------------- | -------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------- | ---------- |
| Identity Provider | Keycloak             | [26.2.5](https://github.com/keycloak/keycloak/releases/tag/26.2.5) | [documentation](https://www.keycloak.org/documentation)       | Apache-2.0 |
| Chat              | Element synapse      | [v1.133](https://github.com/element-hq/synapse/tree/v1.133.0)      | [documentation](https://element-hq.github.io/synapse/latest/) | AGPL-3.0   |
| Notes             | Docs                 | [v3.2.1](https://github.com/suitenumerique/docs/tree/v3.2.1)       |                                                               | MIT        |
| Spreadsheet       | Grist                | [v1.6.1](https://github.com/gristlabs/grist-core/tree/v1.6.1)      | [documentation](https://support.getgrist.com/self-managed/)   | Apache-2.0 |
| AI LLM            | Ollama               | [v0.9.5](https://github.com/ollama/ollama/tree/v0.9.5)             | [documentation](https://ollama.com/)                          | MIT        |

## Requirements

- A Kubernetes cluster (self-managed or cloud-hosted).
- A domain name to expose the applications.
- A supported ingress controller for kubernetes
- (Optional) Production setups should use external datastores conforming to your organization's disaster recovery and security policies.

## Getting started

We use [Helmfile](https://helmfile.readthedocs.io/en/latest/) for managing and deploying all components.

### Prerequisites

- [Helm](https://helm.sh/)
- [helm-secrets](https://github.com/jkroepke/helm-secret).
- [sops](https://getsops.io/)
- [age](https://github.com/FiloSottile/age)

### Setup

Initialize Helm dependencies:

```bash
helmfile init
```

Generate all manifests:

```bash
export MIJNBUREAU_MASTER_PASSWORD=changethis
helmfile template
```

Deploy all components to Kubernetes:

```bash
export MIJNBUREAU_MASTER_PASSWORD=changethis
helmfile apply
```

## Environments & Customization

Helmfile supports multiple environments. The default environment is used if none is specified. Available environments:

- `default`: baseline configuration
- `demo`: includes internal datastores (e.g., PostgreSQL, S3) — great for quick setups
- `production`: excludes internal datastores — assumes preconfigured external services

To deploy a specific environment with a custom namespace:

```bash
export MIJNBUREAU_MASTER_PASSWORD=changethis
helmfile -e production -n icbr-poc-id apply
```

### Overriding Configuration

Override default variables in:

```bash
./helmfile/environments/{environment}/mijnbureau.yaml.gotmpl
```

For example, to change the domainname in the production environment we overwrite the /helmfile/environments/default/global.yaml.gotmpl from the default environment in the file /helmfile/environments/{environment}/mijnbureau.yaml.gotmpl by setting the following content. this can be done for all variables in the default environment.

```yaml
global:
  domain: "mijnbureau.icbr.prd1.gn2.quattro.rijksapps.nl"
```

## Secrets management

Sensitive values (like database passwords) can be securely stored using helm-secrets and sops. We prepared the setup an give an example.secrets.yaml

```bash
./helmfile/environments/{environment}/mijnbureau.yaml.gotmpl
```

### Step-by-step

1. Generate an Age key pair:

```bash
age-keygen -o mykey.txt
```

2. Update .sops.yaml:
   Replace the sample age: entry with your public key.

3. Encrypt a file:

add some values in the example.secrets.yaml and encrypt it.

```bash
helm secrets encrypt -i ./helmfile/environments/production/example.secrets.yaml
```

4. Decrypt for local use:

```bash
export SOPS_AGE_KEY_FILE=./mykey.txt
helm secrets decrypt -i ./helmfile/environments/production/example.secrets.yaml
```

5. Use with helmfile

```bash
export MIJNBUREAU_MASTER_PASSWORD=changethis
export SOPS_AGE_KEY_FILE=./mykey.txt
helmfile template
helmfile apply
```

## Commit Conventions

We use the [gitmoji](https://gitmoji.dev/) commit convention with the following scopes: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

## Additional Resources

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
