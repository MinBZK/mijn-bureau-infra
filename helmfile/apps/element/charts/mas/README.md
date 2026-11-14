<!--- app-name: mas -->

# Matrix Authentication Service (MAS)

[Matrix Authentication Service](https://github.com/element-hq/matrix-authentication-service) is an OAuth 2.0 and OpenID Connect server for Matrix homeservers, used by next-generation Matrix clients (e.g. Element X) and delegating authentication away from Synapse (MSC3861).

## TL;DR

```console
helm install my-release ./charts/mas
```

## Introduction

This chart bootstraps a MAS deployment on a Kubernetes cluster using the Helm package manager.

It deploys:

- the `mas-cli server` workload with a public web listener (`http`, port 8080) and an internal health/metrics listener (`internal`, port 8081);
- a ConfigMap with the non-sensitive `http` configuration block;
- a Secret with all other configuration sections (database, email, matrix, clients, secrets, passwords, policy, branding, upstream OAuth2, ...). Sensitive values are referenced via `*_file` paths pointing at mounted Secret keys;
- a post-install hook Job that generates the cookie-encryption secret and an RSA signing key (via `mas-cli config generate`) and stores them — together with the Matrix shared secret and the OAuth client secrets — in a Secret named `<release>-mas-secrets`. The Job is idempotent: if the Secret already exists it is left untouched;
- an optional post-install/post-upgrade hook Job that creates the MAS role and database on a CloudNativePG cluster (`databaseBootstrap`).

> Warning: never delete the `<release>-mas-secrets` Secret after the first deployment. Losing the encryption secret invalidates all encrypted data in the MAS database.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+
- A PostgreSQL database (CloudNativePG cluster recommended)
- A Matrix homeserver (Synapse) reachable from the cluster

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release ./charts/mas
```

The command deploys MAS on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Configuration and installation details

It is strongly recommended to use immutable tags in a production environment. This ensures your deployment does not change automatically if the same tag is updated with a different image.

## Parameters

The following tables list the configurable parameters of the MAS chart and their default values. See `values.yaml` for the full list and inline documentation.

### Common parameters

| Name                           | Description                                           | Value                                                                |
| ------------------------------ | ----------------------------------------------------- | -------------------------------------------------------------------- |
| `replicaCount`                 | Number of MAS replicas to deploy                      | `1`                                                                  |
| `image.registry`               | MAS image registry                                    | `ghcr.io`                                                            |
| `image.repository`             | MAS image repository                                  | `element-hq/matrix-authentication-service`                           |
| `image.tag`                    | MAS image tag                                         | `""` (defaults to appVersion if set, otherwise the packaged default) |
| `image.pullPolicy`             | MAS image pull policy                                 | `IfNotPresent`                                                       |
| `image.pullSecrets`            | MAS image pull secrets                                | `[]`                                                                 |
| `resourcesPreset`              | Resource preset (ignored if `resources` is set)       | `nano`                                                               |
| `resources`                    | Container resource requests/limits (wins over preset) | `{}`                                                                 |
| `podSecurityContext`           | Pod security context                                  | see values.yaml                                                      |
| `containerSecurityContext`     | Container security context                            | see values.yaml                                                      |
| `automountServiceAccountToken` | Mount SA token in MAS pods                            | `false`                                                              |
| `pdb.create`                   | Create a PodDisruptionBudget                          | `false`                                                              |
| `serviceAccount.create`        | Create the MAS ServiceAccount                         | `true`                                                               |

### Probes

| Name                                                              | Description                                                 | Value           |
| ----------------------------------------------------------------- | ----------------------------------------------------------- | --------------- |
| `livenessProbe`/`readinessProbe`/`startupProbe`                   | Probe configuration; `httpGet /health` on the internal port | see values.yaml |
| `customLivenessProbe`/`customReadinessProbe`/`customStartupProbe` | Custom probes overriding the defaults                       | `{}`            |

### Traffic exposure

| Name                                       | Description                                             | Value       |
| ------------------------------------------ | ------------------------------------------------------- | ----------- |
| `service.ports.http`                       | MAS public web service port                             | `8080`      |
| `service.ports.internal`                   | MAS internal health/metrics service port                | `8081`      |
| `ingress.enabled`                          | Create an Ingress (when `cluster.routingMode=ingress`)  | `true`      |
| `ingress.hostname`                         | Ingress hostname                                        | `mas.local` |
| `networkPolicy.enabled`                    | Create a NetworkPolicy                                  | `true`      |
| `networkPolicy.allowExternal`              | Allow connections from any source                       | `true`      |
| `networkPolicy.allowExternalEgress`        | Allow egress to any destination                         | `true`      |
| `networkPolicy.extraIngress`/`extraEgress` | Extra NetworkPolicy rules                               | `[]`        |
| `metrics.enabled`                          | Enable the Prometheus exporter on the internal listener | `false`     |

### MAS application configuration (`config.*`)

| Name                                         | Description                                      | Default               |
| -------------------------------------------- | ------------------------------------------------ | --------------------- |
| `config.publicBase`                          | Public base URL of MAS                           | `https://mas.local/`  |
| `config.issuer`                              | OIDC issuer URL                                  | `""`                  |
| `config.trustedProxies`                      | Trusted proxy CIDRs                              | private ranges        |
| `config.database.*`                          | PostgreSQL connection (password via file)        | see values.yaml       |
| `config.email.*`                             | SMTP settings (password via file)                | see values.yaml       |
| `config.matrix.homeserver`                   | Synapse server name                              | `example.com`         |
| `config.matrix.endpoint`                     | Synapse URL reachable from MAS                   | `http://synapse:8008` |
| `config.matrix.secret`                       | Synapse↔MAS shared secret (stored by keygen Job) | `""`                  |
| `config.clients`                             | Static OAuth2/OIDC clients (ULID client_id)      | `[]`                  |
| `config.passwords.*`                         | Local password database settings                 | enabled, argon2id     |
| `config.account.passwordRegistrationEnabled` | Self-service registration                        | `false`               |
| `config.policy.extraData`                    | Extra OPA policy data                            | `{}`                  |
| `config.branding.*`                          | Branding of the MAS UI                           | `null`                |
| `config.upstreamOauth2.providers`            | Upstream OAuth2 providers                        | `[]`                  |
| `config.experimental.*`                      | Token TTLs                                       | `86400`               |

### Hook Jobs

| Name                                | Description                                     | Value                                  |
| ----------------------------------- | ----------------------------------------------- | -------------------------------------- |
| `keygenJob.enabled`                 | Create the secret-generation hook Job           | `true`                                 |
| `keygenJob.kubectl.image.*`         | kubectl image used to create the Secret         | `registry.k8s.io/kubectl`              |
| `keygenJob.shell.image.*`           | busybox image (shell for the kubectl container) | `docker.io/busybox:1.37.0-musl`        |
| `keygenJob.resources`               | Resource requests/limits for the Job            | `{}`                                   |
| `databaseBootstrap.enabled`         | Create the CNPG database bootstrap hook Job     | `false`                                |
| `databaseBootstrap.host`/`port`     | CNPG cluster primary endpoint                   | `""`/`5432`                            |
| `databaseBootstrap.superuserSecret` | basic-auth Secret with the CNPG superuser       | `""`                                   |
| `databaseBootstrap.image.*`         | PostgreSQL image providing `psql`               | `ghcr.io/cloudnative-pg/postgresql:17` |
| `rbac.create`                       | Create Role/RoleBinding for the keygen Job      | `true`                                 |

### Scheduling and misc

| Name                                                                              | Description                              | Value                       |
| --------------------------------------------------------------------------------- | ---------------------------------------- | --------------------------- |
| `podLabels`                                                                       | Extra pod labels                         | `{}`                        |
| `podAnnotations`                                                                  | Pod annotations                          | `{}`                        |
| `deploymentAnnotations`                                                           | Deployment annotations                   | `{}`                        |
| `affinity` / `podAffinityPreset` / `podAntiAffinityPreset` / `nodeAffinityPreset` | Affinity rules                           | `{}` / `""` / `soft` / `{}` |
| `nodeSelector`                                                                    | Node labels for pod assignment           | `{}`                        |
| `tolerations`                                                                     | Tolerations for pod assignment           | `[]`                        |
| `runtimeClassName`                                                                | Runtime class for the pods               | `""`                        |
| `priorityClassName`                                                               | Pod priority class                       | `""`                        |
| `lifecycleHooks`                                                                  | Container lifecycle hooks                | `{}`                        |
| `sidecars`                                                                        | Extra sidecar containers                 | `[]`                        |
| `initContainers`                                                                  | Extra init containers                    | `[]`                        |
| `extraEnvVars` / `extraEnvVarsCM` / `extraEnvVarsSecret`                          | Extra environment variables              | `[]` / `""` / `""`          |
| `extraVolumes` / `extraVolumeMounts`                                              | Extra volumes and mounts                 | `[]` / `[]`                 |
| `extraDeploy`                                                                     | Extra objects to deploy with the release | `[]`                        |

## Troubleshooting

Find more information on MAS in the [upstream documentation](https://element-hq.github.io/matrix-authentication-service/).

## License

Licensed under the EUPL-1.2 license.
