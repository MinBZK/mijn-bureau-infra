---
sidebar_position: 2
---

# Intro

This document describes the development process and tools for MijnBureau. It aims to provide an easy and efficient way to contribute to the project.

---

## Getting Started

If you have an idea or want to make changes, you will need to create a Pull Request (PR) on the MijnBureau GitHub repository. For significant changes or new components, it is recommended to first create an [Issue](https://github.com/MinBZK/mijn-bureau-infra/issues) on the repository. This allows you to discuss the change and avoid spending time on something that might be declined due to architectural or business reasons.

### Steps to Contribute

1. **Fork the Repository**:
   - Fork the [MijnBureau repository](https://github.com/MinBZK/mijn-bureau-infra).

2. **Create a Branch**:
   - Create a new branch for your changes.

3. **Submit a Pull Request**:
   - Once your branch is ready, submit a PR on the [GitHub repository](https://github.com/MinBZK/mijn-bureau-infra/pulls).

---

## Tools

To simplify development for new contributors, we provide DevContainers. These containers include all the required tools for developing MijnBureau applications.

### Using DevContainers

To start a DevContainer in VS Code, refer to [this manual](https://code.visualstudio.com/docs/devcontainers/containers).

### Installing Tools Locally

If you prefer not to use DevContainers, you can install the required tools on your machine. The most important tools are:

- [Helmfile](https://helmfile.readthedocs.io/)
- [Helm](https://helm.sh/)

### Additional Tools

For testing and policy adherence, you may need the following tools:

- **Python3**: Required for GitLint.
- **Node.js & npm**: Used for Prettier formatting.
- **[Conftest](https://www.conftest.dev/)**: For policy testing with the Rego language.
- **[Regal](https://github.com/StyraInc/regal/)**: For policy editing.
- **[Kubeconform](https://github.com/yannh/kubeconform)**: For Kubernetes manifest validation.

---

## Helmfile

Helmfile requires plugins to function. Install the necessary plugins by running:

```bash
helmfile init
```
