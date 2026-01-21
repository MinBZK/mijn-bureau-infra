---
sidebar_position: 5
---

# Installation Guide

Follow this guide to install MijnBureau on your Kubernetes cluster. Ensure you are connected to a Kubernetes cluster before proceeding.

---

## Verify Kubernetes Connection

Check which Kubernetes cluster you are connected to by running:

```bash
kubectl config current-context
```

---

## Set Master Password

Set the environment variable for the master password to enable deterministic secret generation:

```bash
export MIJNBUREAU_MASTER_PASSWORD="your-very-secure-password"
```

:::warning Password Security
This password is used to generate most application secrets. Use a strong password and store it securely, as it will be required for future operations.
:::

---

## Configure Additional Variables

By default, MijnBureau does not create a Kubernetes namespace if it does not exist. You can enable automatic namespace creation by setting the following variable:

```bash
export MIJNBUREAU_CREATE_NAMESPACES=true
```

### Namespace Configuration

By default, MijnBureau deploys to your **current Kubernetes context namespace**. Check your current context with:

```bash
kubectl config get-contexts
```

The current context is marked with `*`. To change the target namespace:

```bash
kubectl config set-context --current --namespace=my-namespace
```

For production deployments or per-app isolation, you can override namespaces in your environment configuration. See the [Namespace Configuration](./example-config.md#namespace-configuration) section for details.

---

## Deploy MijnBureau

### Prerequisites

Install and prepare Helmfile and Helm. Refer to their respective documentation for installation instructions:

- [Helmfile Installation Guide](https://helmfile.readthedocs.io/en/latest/#installation)
- [Helm Installation Guide](https://helm.sh/docs/intro/install/)

Once installed, initialize Helmfile:

```bash
helmfile init
```

### Installation

To deploy MijnBureau to your Kubernetes cluster, execute the following command:

```bash
helmfile -e <environment> apply
```

Replace `<environment>` with the desired environment, such as `demo` or `production`. If you do not specify the `-e <environment>` option, MijnBureau will use the default environment.

### Inspect Installation

If you want to inspect the installation without deploying, use the following command:

```bash
helmfile -e <environment> template
```

---

## Additional Helmfile Commands

Helmfile provides many additional commands for managing your deployment. Refer to the [Helmfile CLI Reference](https://helmfile.readthedocs.io/en/latest/#cli-reference) for more details.
