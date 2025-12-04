<!--- app-name: clamav -->

# ClamAV

ClamAV is an open source (GPLv2) anti-virus toolkit, designed especially for e-mail scanning on mail gateways. It provides a number of utilities including a flexible and scalable multi-threaded daemon, a command line scanner and advanced tool for automatic database updates.

## TL;DR

In the root directory of the Helm chart directory:

```console
helm install my-release
```

## Introduction

This chart bootstraps a ClamAV deployment on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+
- PV provisioner support in the underlying infrastructure
- ReadWriteMany volumes for deployment scaling

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release git+https://github.com/MinBZK/mijn-bureau-infra@helmfile/apps/clamav/charts?ref=main
```

The command deploys ClamAV on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Configuration and installation details

### [Rolling VS Immutable tags](https://docs.vmware.com/en/VMware-Tanzu-Application-Catalog/services/tutorials/GUID-understand-rolling-tags-containers-index.html)

It is strongly recommended to use immutable tags in a production environment. This ensures your deployment does not change automatically if the same tag is updated with a different image.

Bitnami will release a new chart updating its containers if a new version of the main container, significant changes, or critical vulnerabilities exist.

### Additional environment variables

In case you want to add extra environment variables (useful for advanced operations like custom init scripts), you can use the `extraEnvVars` property.

```yaml
clamav:
  extraEnvVars:
    - name: LOG_LEVEL
      value: error
```

Alternatively, you can use a ConfigMap or a Secret with the environment variables. To do so, use the `extraEnvVarsCM` or the `extraEnvVarsSecret` values.

### Sidecars

If additional containers are needed in the same pod as ClamAV (such as additional metrics or logging exporters), they can be defined using the `sidecars` parameter.

```yaml
sidecars:
  - name: your-image-name
    image: your-image
    imagePullPolicy: Always
    ports:
      - name: portname
        containerPort: 1234
```

If these sidecars export extra ports, extra port definitions can be added using the `service.extraPorts` parameter (where available), as shown in the example below:

```yaml
service:
  extraPorts:
    - name: extraPort
      port: 11311
      targetPort: 11311
```

> NOTE: This Helm chart already includes sidecar containers for the Prometheus exporters (where applicable). These can be activated by adding the `--enable-metrics=true` parameter at deployment time. The `sidecars` parameter should therefore only be used for any extra sidecar containers.

If additional init containers are needed in the same pod, they can be defined using the `initContainers` parameter. Here is an example:

```yaml
initContainers:
  - name: your-image-name
    image: your-image
    imagePullPolicy: Always
    ports:
      - name: portname
        containerPort: 1234
```

Learn more about [sidecar containers](https://kubernetes.io/docs/concepts/workloads/pods/) and [init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/).

### Pod affinity

This chart allows you to set your custom affinity using the `affinity` parameter. Find more information about Pod affinity in the [kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

As an alternative, use one of the preset configurations for pod affinity, pod anti-affinity, and node affinity available at the [bitnami/common](https://github.com/bitnami/charts/tree/main/bitnami/common#affinities) chart. To do so, set the `podAffinityPreset`, `podAntiAffinityPreset`, or `nodeAffinityPreset` parameters.

## Persistence

The ClamAV image stores the ClamAV data and configurations at the `%PVC_PATH%` path of the container. Persistent Volume Claims are used to keep the data across deployments.

## Parameters

### Global parameters

| Name                                                  | Description                                                                                                                                                                                                                                                                                                                                                         | Value   |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `global.imageRegistry`                                | Global Docker Image registry                                                                                                                                                                                                                                                                                                                                        | `""`    |
| `global.imagePullSecrets`                             | Global Docker registry secret names as an array                                                                                                                                                                                                                                                                                                                     | `[]`    |
| `global.defaultStorageClass`                          | Global default StorageClass for Persistent Volume(s)                                                                                                                                                                                                                                                                                                                | `""`    |
| `global.security.allowInsecureImages`                 | Allows skipping image verification                                                                                                                                                                                                                                                                                                                                  | `false` |
| `global.compatibility.openshift.adaptSecurityContext` | Adapt the securityContext sections of the deployment to make them compatible with Openshift restricted-v2 SCC: remove runAsUser, runAsGroup and fsGroup and let the platform use their allowed default IDs. Possible values: auto (apply if the detected running cluster is Openshift), force (perform the adaptation always), disabled (do not perform adaptation) | `auto`  |
| `global.compatibility.omitEmptySeLinuxOptions`        | If set to true, removes the seLinuxOptions from the securityContexts when it is set to an empty object                                                                                                                                                                                                                                                              | `false` |

### Common parameters

| Name                     | Description                                                                             | Value           |
| ------------------------ | --------------------------------------------------------------------------------------- | --------------- |
| `kubeVersion`            | Override Kubernetes version reported by .Capabilities                                   | `""`            |
| `apiVersions`            | Override Kubernetes API versions reported by .Capabilities                              | `[]`            |
| `nameOverride`           | String to partially override common.names.name                                          | `""`            |
| `fullnameOverride`       | String to fully override common.names.fullname                                          | `""`            |
| `namespaceOverride`      | String to fully override common.names.namespace                                         | `""`            |
| `commonLabels`           | Labels to add to all deployed objects                                                   | `{}`            |
| `commonAnnotations`      | Annotations to add to all deployed objects                                              | `{}`            |
| `clusterDomain`          | Kubernetes cluster domain name                                                          | `cluster.local` |
| `extraDeploy`            | Array of extra objects to deploy with the release                                       | `[]`            |
| `diagnosticMode.enabled` | Enable diagnostic mode (all probes will be disabled and the command will be overridden) | `false`         |
| `diagnosticMode.command` | Command to override all containers in the chart release                                 | `["sleep"]`     |
| `diagnosticMode.args`    | Args to override all containers in the chart release                                    | `["infinity"]`  |

### ClamAv Parameters

| Name                                                       | Description                                                                                                                                                                                                                            | Value            |
| ---------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| `clamav.image.registry`                                    | ClamAv image registry                                                                                                                                                                                                                  | `docker.io`      |
| `clamav.image.repository`                                  | ClamAv image repository                                                                                                                                                                                                                | `clamav/clamav`  |
| `clamav.image.digest`                                      | ClamAv image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag image tag (immutable tags are recommended)                                                                                      | `""`             |
| `clamav.image.pullPolicy`                                  | ClamAv image pull policy                                                                                                                                                                                                               | `Always`         |
| `clamav.image.pullSecrets`                                 | ClamAv image pull secrets                                                                                                                                                                                                              | `[]`             |
| `clamav.image.debug`                                       | Enable ClamAv image debug mode                                                                                                                                                                                                         | `false`          |
| `clamav.replicaCount`                                      | Number of ClamAv replicas to deploy                                                                                                                                                                                                    | `1`              |
| `clamav.containerPorts.clamav`                             | ClamAv TCP container port                                                                                                                                                                                                              | `3310`           |
| `clamav.containerPorts.milter`                             | ClamAv Milter container port                                                                                                                                                                                                           | `7357`           |
| `clamav.extraContainerPorts`                               | Optionally specify extra list of additional ports for ClamAv containers                                                                                                                                                                | `[]`             |
| `clamav.livenessProbe.enabled`                             | Enable livenessProbe on ClamAv containers                                                                                                                                                                                              | `true`           |
| `clamav.livenessProbe.initialDelaySeconds`                 | Initial delay seconds for livenessProbe                                                                                                                                                                                                | `10`             |
| `clamav.livenessProbe.periodSeconds`                       | Period seconds for livenessProbe                                                                                                                                                                                                       | `10`             |
| `clamav.livenessProbe.timeoutSeconds`                      | Timeout seconds for livenessProbe                                                                                                                                                                                                      | `2`              |
| `clamav.livenessProbe.failureThreshold`                    | Failure threshold for livenessProbe                                                                                                                                                                                                    | `3`              |
| `clamav.livenessProbe.successThreshold`                    | Success threshold for livenessProbe                                                                                                                                                                                                    | `1`              |
| `clamav.readinessProbe.enabled`                            | Enable readinessProbe on ClamAv containers                                                                                                                                                                                             | `true`           |
| `clamav.readinessProbe.initialDelaySeconds`                | Initial delay seconds for readinessProbe                                                                                                                                                                                               | `10`             |
| `clamav.readinessProbe.periodSeconds`                      | Period seconds for readinessProbe                                                                                                                                                                                                      | `10`             |
| `clamav.readinessProbe.timeoutSeconds`                     | Timeout seconds for readinessProbe                                                                                                                                                                                                     | `2`              |
| `clamav.readinessProbe.failureThreshold`                   | Failure threshold for readinessProbe                                                                                                                                                                                                   | `3`              |
| `clamav.readinessProbe.successThreshold`                   | Success threshold for readinessProbe                                                                                                                                                                                                   | `1`              |
| `clamav.startupProbe.enabled`                              | Enable startupProbe on ClamAv containers                                                                                                                                                                                               | `false`          |
| `clamav.startupProbe.initialDelaySeconds`                  | Initial delay seconds for startupProbe                                                                                                                                                                                                 | `10`             |
| `clamav.startupProbe.periodSeconds`                        | Period seconds for startupProbe                                                                                                                                                                                                        | `10`             |
| `clamav.startupProbe.timeoutSeconds`                       | Timeout seconds for startupProbe                                                                                                                                                                                                       | `2`              |
| `clamav.startupProbe.failureThreshold`                     | Failure threshold for startupProbe                                                                                                                                                                                                     | `3`              |
| `clamav.startupProbe.successThreshold`                     | Success threshold for startupProbe                                                                                                                                                                                                     | `1`              |
| `clamav.customLivenessProbe`                               | Custom livenessProbe that overrides the default one                                                                                                                                                                                    | `{}`             |
| `clamav.customReadinessProbe`                              | Custom readinessProbe that overrides the default one                                                                                                                                                                                   | `{}`             |
| `clamav.customStartupProbe`                                | Custom startupProbe that overrides the default one                                                                                                                                                                                     | `{}`             |
| `clamav.resourcesPreset`                                   | Set ClamAv container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if clamav.resources is set (clamav.resources is recommended for production). | `nano`           |
| `clamav.resources`                                         | Set ClamAv container requests and limits for different resources like CPU or memory (essential for production workloads)                                                                                                               | `{}`             |
| `clamav.podSecurityContext.enabled`                        | Enable ClamAv pods' Security Context                                                                                                                                                                                                   | `true`           |
| `clamav.podSecurityContext.fsGroupChangePolicy`            | Set filesystem group change policy for ClamAv pods                                                                                                                                                                                     | `Always`         |
| `clamav.podSecurityContext.sysctls`                        | Set kernel settings using the sysctl interface for ClamAv pods                                                                                                                                                                         | `[]`             |
| `clamav.podSecurityContext.supplementalGroups`             | Set filesystem extra groups for ClamAv pods                                                                                                                                                                                            | `[]`             |
| `clamav.podSecurityContext.fsGroup`                        | Set fsGroup in ClamAv pods' Security Context                                                                                                                                                                                           | `1001`           |
| `clamav.containerSecurityContext.enabled`                  | Enabled ClamAv container' Security Context                                                                                                                                                                                             | `true`           |
| `clamav.containerSecurityContext.seLinuxOptions`           | Set SELinux options in ClamAv container                                                                                                                                                                                                | `{}`             |
| `clamav.containerSecurityContext.runAsUser`                | Set runAsUser in ClamAv container' Security Context                                                                                                                                                                                    | `1001`           |
| `clamav.containerSecurityContext.runAsGroup`               | Set runAsGroup in ClamAv container' Security Context                                                                                                                                                                                   | `1001`           |
| `clamav.containerSecurityContext.runAsNonRoot`             | Set runAsNonRoot in ClamAv container' Security Context                                                                                                                                                                                 | `true`           |
| `clamav.containerSecurityContext.readOnlyRootFilesystem`   | Set readOnlyRootFilesystem in ClamAv container' Security Context                                                                                                                                                                       | `true`           |
| `clamav.containerSecurityContext.privileged`               | Set privileged in ClamAv container' Security Context                                                                                                                                                                                   | `false`          |
| `clamav.containerSecurityContext.allowPrivilegeEscalation` | Set allowPrivilegeEscalation in ClamAv container' Security Context                                                                                                                                                                     | `false`          |
| `clamav.containerSecurityContext.capabilities.drop`        | List of capabilities to be dropped in ClamAv container                                                                                                                                                                                 | `["ALL"]`        |
| `clamav.containerSecurityContext.seccompProfile.type`      | Set seccomp profile in ClamAv container                                                                                                                                                                                                | `RuntimeDefault` |
| `clamav.existingConfigmap`                                 | The name of an existing ConfigMap with your custom configuration for ClamAv                                                                                                                                                            | `""`             |
| `clamav.command`                                           | Override default ClamAv container command (useful when using custom images)                                                                                                                                                            | `[]`             |
| `clamav.args`                                              | Override default ClamAv container args (useful when using custom images)                                                                                                                                                               | `[]`             |
| `clamav.automountServiceAccountToken`                      | Mount Service Account token in ClamAv pods                                                                                                                                                                                             | `false`          |
| `clamav.hostAliases`                                       | ClamAv pods host aliases                                                                                                                                                                                                               | `[]`             |
| `clamav.daemonsetAnnotations`                              | Annotations for ClamAv daemonset                                                                                                                                                                                                       | `{}`             |
| `clamav.deploymentAnnotations`                             | Annotations for ClamAv deployment                                                                                                                                                                                                      | `{}`             |
| `clamav.statefulsetAnnotations`                            | Annotations for ClamAv statefulset                                                                                                                                                                                                     | `{}`             |
| `clamav.podLabels`                                         | Extra labels for ClamAv pods                                                                                                                                                                                                           | `{}`             |
| `clamav.podAnnotations`                                    | Annotations for ClamAv pods                                                                                                                                                                                                            | `{}`             |
| `clamav.podAffinityPreset`                                 | Pod affinity preset. Ignored if `clamav.affinity` is set. Allowed values: `soft` or `hard`                                                                                                                                             | `""`             |
| `clamav.podAntiAffinityPreset`                             | Pod anti-affinity preset. Ignored if `clamav.affinity` is set. Allowed values: `soft` or `hard`                                                                                                                                        | `soft`           |
| `clamav.nodeAffinityPreset.type`                           | Node affinity preset type. Ignored if `clamav.affinity` is set. Allowed values: `soft` or `hard`                                                                                                                                       | `""`             |
| `clamav.nodeAffinityPreset.key`                            | Node label key to match. Ignored if `clamav.affinity` is set                                                                                                                                                                           | `""`             |
| `clamav.nodeAffinityPreset.values`                         | Node label values to match. Ignored if `clamav.affinity` is set                                                                                                                                                                        | `[]`             |
| `clamav.affinity`                                          | Affinity for ClamAv pods assignment                                                                                                                                                                                                    | `{}`             |
| `clamav.nodeSelector`                                      | Node labels for ClamAv pods assignment                                                                                                                                                                                                 | `{}`             |
| `clamav.tolerations`                                       | Tolerations for ClamAv pods assignment                                                                                                                                                                                                 | `[]`             |
| `clamav.updateStrategy.type`                               | ClamAv deployment strategy type                                                                                                                                                                                                        | `RollingUpdate`  |
| `clamav.updateStrategy.type`                               | ClamAv statefulset strategy type                                                                                                                                                                                                       | `RollingUpdate`  |
| `clamav.podManagementPolicy`                               | Pod management policy for ClamAv statefulset                                                                                                                                                                                           | `OrderedReady`   |
| `clamav.priorityClassName`                                 | ClamAv pods' priorityClassName                                                                                                                                                                                                         | `""`             |
| `clamav.topologySpreadConstraints`                         | Topology Spread Constraints for ClamAv pod assignment spread across your cluster among failure-domains                                                                                                                                 | `[]`             |
| `clamav.schedulerName`                                     | Name of the k8s scheduler (other than default) for ClamAv pods                                                                                                                                                                         | `""`             |
| `clamav.runtimeClassName`                                  | Name of the runtime class name for ClamAv pods                                                                                                                                                                                         | `""`             |
| `clamav.terminationGracePeriodSeconds`                     | Seconds ClamAv pods need to terminate gracefully                                                                                                                                                                                       | `""`             |
| `clamav.lifecycleHooks`                                    | for ClamAv containers to automate configuration before or after startup                                                                                                                                                                | `{}`             |
| `clamav.extraEnvVars`                                      | Array with extra environment variables to add to ClamAv containers                                                                                                                                                                     | `[]`             |
| `clamav.extraEnvVarsCM`                                    | Name of existing ConfigMap containing extra env vars for ClamAv containers                                                                                                                                                             | `""`             |
| `clamav.extraEnvVarsSecret`                                | Name of existing Secret containing extra env vars for ClamAv containers                                                                                                                                                                | `""`             |
| `clamav.extraVolumes`                                      | Optionally specify extra list of additional volumes for the ClamAv pods                                                                                                                                                                | `[]`             |
| `clamav.extraVolumeMounts`                                 | Optionally specify extra list of additional volumeMounts for the ClamAv containers                                                                                                                                                     | `[]`             |
| `clamav.sidecars`                                          | Add additional sidecar containers to the ClamAv pods                                                                                                                                                                                   | `[]`             |
| `clamav.initContainers`                                    | Add additional init containers to the ClamAv pods                                                                                                                                                                                      | `[]`             |
| `clamav.pdb.create`                                        | Enable/disable a Pod Disruption Budget creation                                                                                                                                                                                        | `true`           |
| `clamav.pdb.minAvailable`                                  | Minimum number/percentage of pods that should remain scheduled                                                                                                                                                                         | `""`             |
| `clamav.pdb.maxUnavailable`                                | Maximum number/percentage of pods that may be made unavailable. Defaults to `1` if both `clamav.pdb.minAvailable` and `clamav.pdb.maxUnavailable` are empty.                                                                           | `""`             |
| `clamav.autoscaling.vpa.enabled`                           | Enable VPA for ClamAv pods                                                                                                                                                                                                             | `false`          |
| `clamav.autoscaling.vpa.annotations`                       | Annotations for VPA resource                                                                                                                                                                                                           | `{}`             |
| `clamav.autoscaling.vpa.controlledResources`               | VPA List of resources that the vertical pod autoscaler can control. Defaults to cpu and memory                                                                                                                                         | `[]`             |
| `clamav.autoscaling.vpa.maxAllowed`                        | VPA Max allowed resources for the pod                                                                                                                                                                                                  | `{}`             |
| `clamav.autoscaling.vpa.minAllowed`                        | VPA Min allowed resources for the pod                                                                                                                                                                                                  | `{}`             |
| `clamav.autoscaling.vpa.updatePolicy.updateMode`           | Autoscaling update policy                                                                                                                                                                                                              | `Auto`           |
| `clamav.autoscaling.hpa.enabled`                           | Enable HPA for ClamAv pods                                                                                                                                                                                                             | `false`          |
| `clamav.autoscaling.hpa.minReplicas`                       | Minimum number of replicas                                                                                                                                                                                                             | `1`              |
| `clamav.autoscaling.hpa.maxReplicas`                       | Maximum number of replicas                                                                                                                                                                                                             | `3`              |
| `clamav.autoscaling.hpa.targetCPU`                         | Target CPU utilization percentage                                                                                                                                                                                                      | `75`             |
| `clamav.autoscaling.hpa.targetMemory`                      | Target Memory utilization percentage                                                                                                                                                                                                   | `""`             |

### ClamAV Configuration

| Name                                   | Description                                                                                                                       | Value   |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `clamav.configuration.streamMaxLength` | Close the connection when the data size limit is exceeded. The value should match your MTA's limit for a maximum attachment size. | `1000M` |
| `clamav.configuration.debug`           | Enable debug messages in libclamav.                                                                                               | `true`  |
| `clamav.configuration.milter.enabled`  | Enable milter service                                                                                                             | `false` |

### Traffic Exposure Parameters

| Name                                    | Description                                                                                                   | Value       |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ----------- |
| `service.type`                          | ClamAv service type                                                                                           | `ClusterIP` |
| `service.ports.clamav`                  | ClamAv service port                                                                                           | `3310`      |
| `service.ports.milter`                  | Milter service port                                                                                           | `7357`      |
| `service.nodePorts.clamav`              | Node port for ClamAv                                                                                          | `""`        |
| `service.nodePorts.milter`              | Node port for Milter                                                                                          | `""`        |
| `service.clusterIP`                     | ClamAv service Cluster IP                                                                                     | `""`        |
| `service.loadBalancerIP`                | ClamAv service Load Balancer IP                                                                               | `""`        |
| `service.loadBalancerSourceRanges`      | ClamAv service Load Balancer sources                                                                          | `[]`        |
| `service.externalTrafficPolicy`         | ClamAv service external traffic policy                                                                        | `Cluster`   |
| `service.annotations`                   | Additional custom annotations for ClamAv service                                                              | `{}`        |
| `service.extraPorts`                    | Extra ports to expose in ClamAv service (normally used with the `sidecars` value)                             | `[]`        |
| `service.sessionAffinity`               | Control where client requests go, to the same pod or round-robin                                              | `None`      |
| `service.sessionAffinityConfig`         | Additional settings for the sessionAffinity                                                                   | `{}`        |
| `networkPolicy.enabled`                 | Specifies whether a NetworkPolicy should be created                                                           | `true`      |
| `networkPolicy.allowExternal`           | Don't require server label for connections                                                                    | `true`      |
| `networkPolicy.allowExternalEgress`     | Allow the pod to access any range of port and all destinations.                                               | `true`      |
| `networkPolicy.addExternalClientAccess` | Allow access from pods with client label set to "true". Ignored if `networkPolicy.allowExternal` is true.     | `true`      |
| `networkPolicy.extraIngress`            | Add extra ingress rules to the NetworkPolicy                                                                  | `[]`        |
| `networkPolicy.extraEgress`             | Add extra ingress rules to the NetworkPolicy (ignored if allowExternalEgress=true)                            | `[]`        |
| `networkPolicy.ingressPodMatchLabels`   | Labels to match to allow traffic from other pods. Ignored if `networkPolicy.allowExternal` is true.           | `{}`        |
| `networkPolicy.ingressNSMatchLabels`    | Labels to match to allow traffic from other namespaces. Ignored if `networkPolicy.allowExternal` is true.     | `{}`        |
| `networkPolicy.ingressNSPodMatchLabels` | Pod labels to match to allow traffic from other namespaces. Ignored if `networkPolicy.allowExternal` is true. | `{}`        |

### Persistence Parameters

| Name                        | Description                                                                                             | Value               |
| --------------------------- | ------------------------------------------------------------------------------------------------------- | ------------------- |
| `persistence.enabled`       | Enable persistence using Persistent Volume Claims                                                       | `true`              |
| `persistence.mountPath`     | Path to mount the volume at.                                                                            | `/var/lib/clamav`   |
| `persistence.subPath`       | The subdirectory of the volume to mount to, useful in dev environments and one PV for multiple services | `""`                |
| `persistence.storageClass`  | Storage class of backing PVC                                                                            | `""`                |
| `persistence.annotations`   | Persistent Volume Claim annotations                                                                     | `{}`                |
| `persistence.accessModes`   | Persistent Volume Access Modes                                                                          | `["ReadWriteOnce"]` |
| `persistence.size`          | Size of data volume                                                                                     | `8Gi`               |
| `persistence.dataSource`    | Custom PVC data source                                                                                  | `{}`                |
| `persistence.existingClaim` | The name of an existing PVC to use for persistence                                                      | `""`                |
| `persistence.selector`      | Selector to match an existing Persistent Volume for WordPress data PVC                                  | `{}`                |

### Default init containers Parameters

### Other Parameters

| Name                                          | Description                                                      | Value  |
| --------------------------------------------- | ---------------------------------------------------------------- | ------ |
| `serviceAccount.create`                       | Specifies whether a ServiceAccount should be created             | `true` |
| `serviceAccount.name`                         | The name of the ServiceAccount to use.                           | `""`   |
| `serviceAccount.annotations`                  | Additional Service Account annotations (evaluated as a template) | `{}`   |
| `serviceAccount.automountServiceAccountToken` | Automount service account token for the server service account   | `true` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
helm install my-release -f values.yaml oci://REGISTRY_NAME/REPOSITORY_NAME/clamav
```

> Note: You need to substitute the placeholders `REGISTRY_NAME` and `REPOSITORY_NAME` with a reference to your Helm chart registry and repository. For example, in the case of Bitnami, you need to use `REGISTRY_NAME=registry-1.docker.io` and `REPOSITORY_NAME=bitnamicharts`.
> **Tip**: You can use the default [values.yaml](https://github.com/MinBZK/mijn-bureau-infra/blob/main/helmfile/apps/clamav/charts/clamav/values.yaml)

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
