---
sidebar_position: 30
---

# Installation

This guide installs MijnBureau on an existing Kubernetes cluster: obtain the
software, pick an environment, configure it, and run Helmfile. It assumes the
[prerequisites](./prerequisites.md) are met and that `kubectl` points at the
cluster you want to deploy to.

```bash
kubectl config current-context
```

## 1. Obtain the software

Clone the [repository](https://github.com/MinBZK/mijn-bureau-infra):

```bash
git clone https://github.com/MinBZK/mijn-bureau-infra
```

Or download a [release](https://github.com/MinBZK/mijn-bureau-infra/releases) and
extract the tarball:

```bash
tar -xzvf helmfile-v1.2.3.tar.gz
```

Every release publishes the container images it deploys, their SBOMs and their
vulnerabilities. Verify the tarball before deploying it:

```bash
cosign verify-blob --key cosign.pub \
  --bundle helmfile-v1.2.3.tar.gz.sigstore.json helmfile-v1.2.3.tar.gz
```

See [Supply chain and release reports](../security/supply-chain.md) for the
published artifacts and how to verify them.

## 2. Choose an environment

MijnBureau ships three environments. Start from `demo` for evaluation and
`production` for anything real; `default` is the shared base the other two build
on.

| Environment | Purpose                                        | Includes external datastores                          | Configuration                       |
| ----------- | ---------------------------------------------- | ----------------------------------------------------- | ----------------------------------- |
| Default     | Base configuration, used when no `-e` is given | No                                                    | `helmfile/environments/default/`    |
| Demo        | Testing and evaluation                         | Yes, bundled in the cluster                           | `helmfile/environments/demo/`       |
| Production  | Enterprise deployments                         | No, you provide PostgreSQL, Valkey and object storage | `helmfile/environments/production/` |

The demo environment does not include backup and restore. Add them if the data
matters, see [Backup and restore](../operating/backup-restore.md).

:::warning
Do not run `production` without external datastores. It expects PostgreSQL,
Valkey and an S3-compatible object store to already exist; see
[Datastores](../operating/datastores/index.md).
:::

## 3. Configure

### Master password

Most application secrets are derived from one master password, so it must be
stable across deployments and stored safely. A different value rotates every
generated password and locks users out of existing data.

```bash
# Generate a random master password (minimum 20 characters, machine-generated):
openssl rand -base64 24
export MIJNBUREAU_MASTER_PASSWORD="paste-the-generated-value-here"
```

:::warning Password security
The password must be at least 20 random characters (see
[Master password strength](../operating/secrets/derived.md#master-password-strength)).
Losing it means losing access to the derived secrets, including the database and
identity provider credentials.
:::

### Namespaces

By default, MijnBureau does not create a namespace that does not exist. Enable
automatic creation, or make sure the namespaces exist:

```bash
export MIJNBUREAU_CREATE_NAMESPACES=true
```

MijnBureau deploys into the namespace of your current Kubernetes context:

```bash
kubectl config get-contexts   # the current context is marked with *
kubectl config set-context --current --namespace=my-namespace
```

For per-app isolation, override namespaces in your environment configuration;
see [Example configuration](./example-config.md#namespace-configuration).

### Overrides

The default environment lives in `./helmfile/environments/default/<file>.gotmpl`.
Override individual settings by copying the relevant block into
`./helmfile/environments/{environment}/mijnbureau.yaml.gotmpl`, where
`{environment}` is `demo` or `production`.

Example: changing the domain name, copied from
`./helmfile/environments/default/global.yaml.gotmpl` into the production
`mijnbureau.yaml.gotmpl`:

```yaml
global:
  domain: "mijnbureau.mydomain.com"
```

This works for any value from the default environment. For larger setups, split
`mijnbureau.yaml.gotmpl` into several files; they are loaded alphabetically.

## 4. Install the cluster prerequisites

Install [Helm](https://helm.sh/docs/intro/install/) and
[Helmfile](https://helmfile.readthedocs.io/en/latest/#installation), then
initialize Helmfile once:

```bash
helmfile init
```

The bundled demo databases use [CloudNativePG](https://cloudnative-pg.io/).
Install the operator and its CRDs once per cluster before running Helmfile:

```bash
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.27/releases/cnpg-1.27.4.yaml
kubectl rollout status deployment -n cnpg-system cnpg-controller-manager
```

Other cluster-wide components (Gateway API, cert-manager, storage) are documented
in [Prerequisites](./prerequisites.md).

## 5. Deploy

```bash
helmfile -e <environment> apply
```

Replace `<environment>` with `demo` or `production`. Without `-e`, Helmfile uses
the default environment.

Render the manifests without touching the cluster when you want to review the
result first:

```bash
helmfile -e <environment> template
```

## 6. Next steps

- [Example configuration](./example-config.md): domains, namespaces, resources.
- [Single VPS with K3s](./single-vps-k3s.md): a complete small deployment.
- [Administration](../operating/administration.md): admin surfaces and
  break-glass access after installation.
- [Upgrades and rollback](../operating/upgrades.md): moving an installation to a
  newer release.
- [Troubleshooting](../operating/troubleshooting.md): when a release does not
  converge.
