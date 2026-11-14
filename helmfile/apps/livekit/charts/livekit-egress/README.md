# LiveKit Egress

[LiveKit Egress](https://github.com/livekit/livekit) is the recording and streaming
component of LiveKit. The chart deploys the egress worker that records and streams
LiveKit rooms.

## Parameters

| Parameter           | Description                                                      |
| ------------------- | ---------------------------------------------------------------- |
| `global`            | Global parameters shared with subcharts                          |
| `kubeVersion`       | Override Kubernetes version reported by `.Capabilities`          |
| `apiVersions`       | Override Kubernetes API versions reported by `.Capabilities`     |
| `nameOverride`      | String to partially override `common.names.name`                 |
| `fullnameOverride`  | String to fully override `common.names.fullname`                 |
| `namespaceOverride` | String to fully override `common.names.namespace`                |
| `commonLabels`      | Labels to add to all deployed objects                            |
| `commonAnnotations` | Annotations to add to all deployed objects                       |
| `clusterDomain`     | Kubernetes cluster domain name                                   |
| `extraDeploy`       | Array of extra objects to deploy with the release                |
| `egress`            | LiveKit Egress parameters (image, configuration and credentials) |
| `service`           | Service parameters for the egress deployment                     |
| `networkPolicy`     | Network policy parameters                                        |
| `serviceAccount`    | Service account (RBAC) parameters                                |
