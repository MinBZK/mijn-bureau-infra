# MijnBureau Infrastructure - AI Coding Agent Instructions

This document provides guidance for AI coding agents working on the MijnBureau infrastructure repository.

## About this Project

This repository contains the infrastructure for MijnBureau, a collaborative suite for civil servants. It uses Helmfile to manage Kubernetes deployments for various applications like Keycloak, Ollama, and Synapse/Element for chat. The infrastructure is designed to be secure, sovereign, and flexible.

The documentation for this project is built with Docusaurus and is located in the `docs/` directory.

## Technology Stack

- **Kubernetes Manifests**: Managed with [Helm](https://helm.sh/) and [Helmfile](https://helmfile.readthedocs.io/).
- **Policy as Code**: [Conftest](https://www.conftest.dev/) is used with [Rego](https://www.openpolicyagent.org/docs/latest/policy-language/) policies to test the generated Kubernetes manifests.
- **CI/CD**: GitHub Actions are used for continuous integration and deployment. See `.github/workflows/ci.yaml`.
- **Documentation**: [Docusaurus](https://docusaurus.io/) is used for the project documentation.
- **Secrets Management**: [SOPS](https://github.com/getsops/sops) is used for encrypting secrets.

## Developer Workflow

### Setup

1.  Install [Helm](https://helm.sh/docs/intro/install/).
2.  Install [Helmfile](https://helmfile.readthedocs.io/en/latest/#installation).
3.  Install [Conftest](https://www.conftest.dev/install/).

### Testing

The primary testing workflow involves rendering Helm charts and then running Conftest policies against the generated manifests.

The main test script is `scripts/test.sh`. It can be run locally to validate changes.

```bash
./scripts/test.sh
```

This script iterates through the test case definitions in `tests/*.yaml`, renders the templates for each, and then runs the corresponding policies from `tests/<test-name>/*.rego`.

### Linting

- **Helmfile**: `helmfile lint` is used to lint the Helmfile setup.
- **Commit Messages**: This repository uses [gitmoji](https://gitmoji.dev/) commit conventions. Commit messages are linted using `gitlint`.

### Documentation

The documentation is in the `docs/` directory. To start the Docusaurus development server, you can use the "Docusaurus Dev Server" launch configuration in VS Code, or run:

```bash
cd docs
npm install
npm start
```

## Project Structure

- `helmfile/`: Contains the core Helmfile setup.
  - `helmfile/apps/`: Contains the Helmfile configurations for each application (e.g., `projects`, `keycloak`). Each app has a `helmfile-child.yaml.gotmpl` and its own chart or dependency.
  - `helmfile/bases/`: Contains base Helmfile configurations.
  - `helmfile/environments/`: Contains environment-specific values.
- `policy/`: Contains global Rego policies that are applied to all environments.
- `tests/`: Contains test cases for the Helm charts. Each `.yaml` file in the root of `tests/` represents a test environment. The corresponding `.rego` files for that test are in a directory with the same name (e.g., `tests/global-config-rules/`).
- `scripts/`: Contains various utility scripts for testing, linting, and formatting.
- `docs/`: Contains the Docusaurus documentation.

## Deployment

Deployments are managed via Helmfile. The `.github/workflows/ci.yaml` file defines the CI/CD pipeline. When changes are pushed, the following key jobs are run:

- `lint-helmfile`: Lints the Helmfile configuration.
- `render-helmfile`: Renders the Kubernetes manifests to ensure there are no templating errors.
- `verify-policies`: Runs the Conftest policies against the rendered manifests.

Secrets are managed with SOPS and should be encrypted. The CI pipeline uses secrets for the master password and SOPS AGE key.
