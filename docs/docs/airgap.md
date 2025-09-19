---
sidebar_position: 11
---

# Airgap

Airgapped environments, which lack internet access, require special preparation. This documentation outlines the steps needed to set up MijnBureau in such environments. Ensure all required tools, repositories, charts, and containers are downloaded and transferred to a datastore that can be moved to the airgapped environment.

---

## Download Tools

Download the following tools and their required plugins:

- **Helmfile**: [Installation Guide](https://helmfile.readthedocs.io/en/latest/#installation)
- **Helm**: [Installation Guide](https://helm.sh/docs/intro/install/)
- **Helm Secrets**: [Documentation](https://github.com/jkroepke/helm-secrets)
- **Helm Diff**: [Documentation](https://github.com/databus23/helm-diff)
- **Helm Git**: [Documentation](https://github.com/aslafy-z/helm-git)
- **Helm S3**: [Documentation](https://github.com/hypnoglow/helm-s3)

> Note: Additional tools may be required for testing and development, but these are typically not used in airgapped environments.

---

## Clone the Repository

Ensure you clone the MijnBureau infrastructure repository:

```bash
git clone https://github.com/MinBZK/mijn-bureau-infra
```

---

## Download Charts and Containers

Use the provided script to download all charts and containers required by MijnBureau:

```bash
./scripts/airgap_prepare.py
```
