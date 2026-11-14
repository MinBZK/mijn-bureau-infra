# Observability

The observability chart ships Grafana dashboards as `GrafanaDashboard` custom
resources for the [grafana-operator](https://github.com/grafana/grafana-operator).
Each JSON file under `dashboards/` becomes a `GrafanaDashboard`, picked up by any
Grafana instance whose labels match the configured instance selector.

## Parameters

| Parameter           | Description                                                         |
| ------------------- | ------------------------------------------------------------------- |
| `kubeVersion`       | Override Kubernetes version reported by `.Capabilities`             |
| `apiVersions`       | Override Kubernetes API versions reported by `.Capabilities`        |
| `nameOverride`      | String to partially override `common.names.name`                    |
| `fullnameOverride`  | String to fully override `common.names.fullname`                    |
| `namespaceOverride` | String to fully override `common.names.namespace`                   |
| `commonLabels`      | Labels to add to all deployed objects                               |
| `commonAnnotations` | Annotations to add to all deployed objects                          |
| `clusterDomain`     | Kubernetes cluster domain name                                      |
| `dashboard`         | Dashboard parameters (labels, instance selector and folder targets) |
