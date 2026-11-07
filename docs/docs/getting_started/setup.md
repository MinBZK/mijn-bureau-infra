---
sidebar_position: 3
---

# Setup

To set up MijnBureau and install it on Kubernetes, you first need to obtain the software. You can either clone the [repository](https://github.com/MinBZK/mijn-bureau-infra) or download a [release](https://github.com/MinBZK/mijn-bureau-infra/releases).

---

## Obtain the Software

### Clone the Repository

If you are familiar with Git, clone the repository:

```bash
git clone https://github.com/MinBZK/mijn-bureau-infra
```

### Download a Release

Alternatively, download a release and extract the tarball:

```bash
tar -xzvf mijnbureau.tar.gz
```

Once you have the software on your machine, you can begin configuring the application.

---

## Configuration

MijnBureau supports multiple deployment environments. It is recommended to use the Demo or Production environment to simplify configuration and avoid conflicts when updating to newer versions.

### 🏠 Default Environment

- **Purpose**: Used by default if no environment is specified.
- **Includes**: Core applications excluding external data stores.
- **Configuration**: `helmfile/environments/default/`

> **Recommendation**: Avoid using the default environment for production. It is configured similarly to the production environment but lacks customization.

### 🚀 Demo Environment

- **Purpose**: Testing and evaluation.
- **Includes**: Core applications, including external data stores like caches, databases, and object stores.
- **Configuration**: `helmfile/environments/demo/`

The demo environment is ideal for testing and evaluation. However, it does not include backup and restore capabilities. Add these features if required for your use case.

### 🏢 Production Environment

- **Purpose**: Enterprise deployments.
- **Includes**: Core applications excluding external data stores.
- **Configuration**: `helmfile/environments/production/`

For production setups, you need to configure external services such as:

- **Database**: PostgreSQL.
- **Cache**: Valkey (Redis-compatible).
- **Object Store**: MinIO.

Additionally, ensure you set up backup and restore procedures, disaster recovery, and persistent volume claim backups.

---

## Overriding Configuration

By default, MijnBureau uses configurations from the default environment, located at:

```bash
./helmfile/environments/default/<file>.gotmpl
```

You can override settings by copying partial content from the default environment files and pasting it into the `mijnbureau.yaml.gotmpl` file for your chosen environment:

```bash
./helmfile/environments/{environment}/mijnbureau.yaml.gotmpl
```

Replace `{environment}` with `demo` or `production`.

### Example: Overriding the Domain Name

To change the domain name in the production environment, copy the relevant variables from `./helmfile/environments/default/global.yaml.gotmpl` and add them to `./helmfile/environments/production/mijnbureau.yaml.gotmpl`:

```yaml
global:
  domain: "mijnbureau.mydomain.com"
```

This approach can be used to override any variable from the default environment. For better manageability, you can split `mijnbureau.yaml.gotmpl` into multiple files.
