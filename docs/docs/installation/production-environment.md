---
sidebar_position: 1
---

# Production environment

Deploy MijnBureau in production mode with external datastores for enterprise-grade reliability, security, and scalability.
:::info Production Architecture
Production deployments use external datastores (PostgreSQL, Redis, MinIO) that you manage separately. This provides better security, backup capabilities, and operational control. See [ADR-MB-006](/docs/development/adr/adr-mb-006.md) for the architectural reasoning.
:::

## Installation steps

### 1. Set up external datastores

The production environment requires external datastores to be setup. These are not managed by MijnBureau.

### 2. Make sure all prerequisites are installed

See the [prerequisites section](/docs/getting_started/prerequisites.md) for all required dependencies.

### 3. Clone the repository

```bash
git clone https://github.com/MinBZK/mijn-bureau-infra.git
cd mijn-bureau-infra
```

### 4. Set master password

Set the environment variable for the master password for deterministic secret generation.

```bash
export MIJNBUREAU_MASTER_PASSWORD="your-very-secure-password"
```

:::warning Password Security
This password generates all application secrets. Use a strong password and store it securely - you'll need it for future operations.
:::

### 5. Configure production environment

Create your production configuration.

### 6. Genrate and review manifests

It is best to first review the generated manifests before deploying them. You can do this by running

```bash
helmfile -e production template --output-dir ./production-output
```

The directory `production-output` now contains all generated Kubernetes manifests.

### 7. Deploy to production

If everything looks good, you are ready to deploy! You can do this by running

```bash
helmfile -e production apply
```
