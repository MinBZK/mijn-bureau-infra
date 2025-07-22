---
sidebar_position: 1
---

# Demo environment

Deploy the MijnBureau in demo mode for testing and evaluation. This deployment will deploy all application
with all required dependencies.

## Installation steps

### 1. Make sure all prerequisites are installed

See the [prerequisites section](/docs/getting_started/prerequisites.md) for all required dependencies.

### 2. Clone the repository

```bash
git clone https://github.com/MinBZK/mijn-bureau-infra.git
cd mijn-bureau-infra
```

### 3. Set master password

Set the environment variable for the master password for deterministic secret generation.

```bash
export MIJNBUREAU_MASTER_PASSWORD="your-very-secure-password"
```

:::warning Password Security
This password generates all application secrets. Use a strong password and store it securely - you'll need it for future operations.
:::

### 4. Apply Kubernetes manifests

To directly apply all the MijnBureau demo Kubernetes manifests you can run

```bash
helmfile -e demo apply
```

If you want to inspect the Kubernetes manifests without deploying you can run

```bash
helmfile -e demo template
```
