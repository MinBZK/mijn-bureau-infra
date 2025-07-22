---
sidebar_position: 1
---

# Overview

MijnBureau is a Kubernetes-native digital workplace suite designed for government and enterprise organizations.
Deploy secure, compliant, and self-hosted applications using our Infrastructure as Code approach with [Helmfile](https://helmfile.readthedocs.io/en/latest/).
Helmfile is used to generate and manage Kubernetes manifests, providing a declarative way to deploy complex application stacks.

## How Helmfile works

A brief overview of the template generation workflow is as follows: setup environment, generate Kubernetes manifests and apply those manifests.

```bash
# 1. Set environment and secrets
export MIJNBUREAU_MASTER_PASSWORD="your-secure-password"

# 2. Optionally generate Kubernetes manifests
helmfile -e demo template

# 3. Apply to cluster
helmfile -e demo apply
```

## Environment driven configuration

MijnBureau supports multiple deployment environments:

### 🚀 Demo environment

- **Purpose**: Testing and evaluation
- **Includes**: All dependencies (databases, caches, objectstores)
- **Configuration**: `helmfile/environment/demo/`

### 🏢 Production environment

- **Purpose**: Enterprise deployments
- **Requires**: External datastores
- **Configuration**: `helmfile/environment/production/`
