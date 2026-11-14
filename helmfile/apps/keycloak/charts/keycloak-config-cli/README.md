<!--- app-name: keycloak-config-cli -->

# keycloak-config-cli

Import [adorsys/keycloak-config-cli](https://github.com/adorsys/keycloak-config-cli) realm configuration into Keycloak with a Helm hook Job.

## TL;DR

```console
helm install my-release git+https://github.com/MinBZK/mijn-bureau-infra@helmfile/apps/keycloak/charts/keycloak-config-cli?ref=main
```

## Introduction

This chart runs a one-shot Kubernetes Job (as a post-install, post-upgrade and post-rollback Helm hook) that imports realm configuration files into a Keycloak server using keycloak-config-cli. Realm files are provided through `import.files` (mounted at `/config`) and environment variables for variable substitution are provided through `import.secrets`.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+
- A reachable Keycloak instance with an admin credentials secret

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release git+https://github.com/MinBZK/mijn-bureau-infra@helmfile/apps/keycloak/charts/keycloak-config-cli?ref=main
```

The command deploys the keycloak-config-cli import Job on the Kubernetes cluster. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Configuration and installation details

### Variable substitution

When `import.varSubstitutionEnabled` is `true`, `$(env:VARIABLE_NAME)` placeholders in the realm files are replaced from the container environment. Supply the values through `import.secrets`:

```yaml
import:
  secrets:
    MB_CLIENT_SECRET_DRIVE: my-secret-value
```

They are stored in a Secret and exposed to the Job with `envFrom`, so they never end up in plain sight in the ConfigMap.

### Additional environment variables

Use `extraEnvVars`, `extraEnvVarsCM` or `extraEnvVarsSecret` to add more environment variables to the Job container.

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker Image registry                    | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]`  |

### Common parameters

| Name                | Description                                     | Value |
| ------------------- | ----------------------------------------------- | ----- |
| `nameOverride`      | String to partially override common.names.name  | `""`  |
| `fullnameOverride`  | String to fully override common.names.fullname  | `""`  |
| `namespaceOverride` | String to fully override common.names.namespace | `""`  |
| `commonLabels`      | Labels to add to all deployed objects           | `{}`  |
| `commonAnnotations` | Annotations to add to all deployed objects      | `{}`  |

### keycloak-config-cli parameters

| Name                              | Description                                                                                                                  | Value                          |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ------------------------------ |
| `image.registry`                  | keycloak-config-cli image registry                                                                                           | `docker.io`                    |
| `image.repository`                | keycloak-config-cli image repository                                                                                         | `adorsys/keycloak-config-cli`  |
| `image.tag`                       | keycloak-config-cli image tag                                                                                                | `6.5.1-26.5.5`                 |
| `image.digest`                    | keycloak-config-cli image digest (overrides tag)                                                                             | `""`                           |
| `image.pullPolicy`                | keycloak-config-cli image pull policy                                                                                        | `Always`                       |
| `imagePullSecrets`                | Image pull secrets                                                                                                           | `[]`                           |
| `keycloak.url`                    | Base URL of the Keycloak server                                                                                              | `http://keycloak-headless:80/` |
| `keycloak.user`                   | Keycloak admin user used for the import                                                                                      | `admin`                        |
| `keycloak.existingSecret`         | Existing secret holding the Keycloak admin password                                                                          | `keycloak-keycloak`            |
| `keycloak.existingSecretKey`      | Key in the existing secret holding the Keycloak admin password                                                               | `admin-password`               |
| `import.filesLocations`           | Locations of the realm import files inside the container                                                                     | `/config/*`                    |
| `import.varSubstitutionEnabled`   | Enable variable substitution in the import files                                                                             | `true`                         |
| `import.availabilityCheckEnabled` | Wait for Keycloak to be available before importing                                                                           | `true`                         |
| `import.availabilityCheckTimeout` | Timeout for the Keycloak availability check                                                                                  | `600s`                         |
| `import.files`                    | Map of import file names to file content, mounted at `/config`                                                               | `{}`                           |
| `import.secrets`                  | Map of environment variable names to secret values for variable substitution                                                 | `{}`                           |
| `serviceAccountName`              | Existing ServiceAccount to use for the Job pods                                                                              | `keycloak`                     |
| `automountServiceAccountToken`    | Mount Service Account token in pods                                                                                          | `false`                        |
| `command`                         | Override default container command                                                                                           | `[]`                           |
| `args`                            | Override default container args                                                                                              | `[]`                           |
| `resourcesPreset`                 | Resources preset for the container (none, nano, micro, small, medium, large, xlarge, 2xlarge). Ignored if `resources` is set | `none`                         |
| `resources`                       | Container resource requests and limits                                                                                       | `{}`                           |
| `podSecurityContext`              | Pod Security Context (leave `{}` to disable)                                                                                 | `{}`                           |
| `securityContext`                 | Container Security Context (leave `{}` to disable)                                                                           | `{}`                           |
| `jobAnnotations`                  | Annotations for the Job                                                                                                      | `{}`                           |
| `podLabels`                       | Extra labels for pods                                                                                                        | `{}`                           |
| `podAnnotations`                  | Annotations for pods                                                                                                         | `{}`                           |
| `affinity`                        | Affinity for pod assignment                                                                                                  | `{}`                           |
| `nodeSelector`                    | Node labels for pod assignment                                                                                               | `{}`                           |
| `tolerations`                     | Tolerations for pod assignment                                                                                               | `[]`                           |
| `runtimeClassName`                | Runtime class name for pods                                                                                                  | `""`                           |
| `extraEnvVars`                    | Extra environment variables for the container                                                                                | `[]`                           |
| `extraEnvVarsCM`                  | Existing ConfigMap with extra environment variables                                                                          | `""`                           |
| `extraEnvVarsSecret`              | Existing Secret with extra environment variables                                                                             | `""`                           |
| `extraVolumes`                    | Extra volumes for the pods                                                                                                   | `[]`                           |
| `extraVolumeMounts`               | Extra volume mounts for the container                                                                                        | `[]`                           |

### Job parameters

| Name                          | Description                                          | Value |
| ----------------------------- | ---------------------------------------------------- | ----- |
| `job.backoffLimit`            | Number of retries before marking the Job as failed   | `1`   |
| `job.ttlSecondsAfterFinished` | Time to keep finished Jobs before automatic cleanup  | `300` |
| `job.hookWeight`              | Helm hook weight, controls ordering across hook Jobs | `"5"` |

### Network policies

| Name                    | Description                                  | Value  |
| ----------------------- | -------------------------------------------- | ------ |
| `networkPolicy.enabled` | Specifies whether a NetworkPolicy is created | `true` |
| `networkPolicy.egress`  | Array of egress rules for the NetworkPolicy  | `[{}]` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`, or provide a YAML file with `-f values.yaml`.

## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
