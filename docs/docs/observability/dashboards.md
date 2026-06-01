# Dashboards

MijnBureau ships **Grafana dashboards as Kubernetes resources**. When you deploy MijnBureau on a cluster that already runs Grafana managed by the [grafana-operator](https://grafana.github.io/grafana-operator/), our dashboards appear automatically in your existing Grafana — no clicking, no JSON uploads.

Internally this is handled by the `observability` Helm release ([helmfile/apps/observability/](https://github.com/MinBZK/mijn-bureau-infra/tree/main/helmfile/apps/observability)). For every JSON file under the chart's `dashboards/` folder, the release emits one `GrafanaDashboard` custom resource. The grafana-operator picks it up via a label selector and pushes the dashboard into the matching Grafana instance.

---

## Prerequisites

The cluster admin (not this repo) must install:

- The [grafana-operator](https://grafana.github.io/grafana-operator/) — provides the `Grafana`, `GrafanaDashboard`, and `GrafanaDatasource` CRDs.
- A `Grafana` custom resource with labels matching the `instanceSelector` configured below (default: `dashboards: "grafana"`).
- A `GrafanaDatasource` of type `prometheus` (or a Prometheus-compatible backend like Mimir or Thanos).
- A Prometheus stack scraping cluster metrics (e.g. [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)).

When these are in place, enable dashboards in your environment values.

---

## Enabling dashboards

Dashboards are **off by default** so installs without Grafana are not broken.

In your environment values (e.g. `helmfile/environments/<env>/metric.yaml.gotmpl`):

```yaml
metric:
  enabled: true
  namespace: monitoring # where Grafana lives — see Metrics docs
  grafanaDashboards:
    enabled: true
    # Selects the target Grafana instance via labels on the Grafana CR.
    instanceSelector:
      matchLabels:
        dashboards: "grafana"
    # Grafana folder where the dashboards appear. Leave empty for root.
    folder: "Mijn Bureau"
    # How often the operator re-applies the dashboard JSON.
    resyncPeriod: "5m"
    # Allow a GrafanaDashboard CR to match a Grafana CR in a different namespace.
    allowCrossNamespaceImport: true
    # Map dashboard JSON __inputs entries to actual Grafana datasource names.
    # See "Datasource mapping" below for details.
    datasources:
      - inputName: DS_PROMETHEUS
        datasourceName: Prometheus
```

Then deploy as usual:

```bash
helmfile -e <environment> apply
```

---

## Default dashboards

Three dashboards ship out of the box, giving you a **cluster → pod → host** drill-down without any extra setup. All appear in Grafana under the `Mijn Bureau` folder.

| Dashboard                 | Source                                                             | Use it to answer                  |
| ------------------------- | ------------------------------------------------------------------ | --------------------------------- |
| General overview          | custom (this repo)                                                 | "Is the cluster healthy overall?" |
| Kubernetes / Views / Pods | [grafana.com #15760](https://grafana.com/grafana/dashboards/15760) | "Which pod is the problem?"       |
| Node Exporter Full        | [grafana.com #1860](https://grafana.com/grafana/dashboards/1860)   | "Is the underlying host healthy?" |

Every panel uses metrics included in [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) by default — no additional exporters required.

### General overview

[dashboards/general-overview.json](https://github.com/MinBZK/mijn-bureau-infra/tree/main/helmfile/apps/observability/charts/observability/dashboards/general-overview.json) — a cluster-wide picture of resource usage. Intentionally application-agnostic, so it works regardless of which MijnBureau apps are enabled.

| Panel                    | What it shows                                                                                                                               |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **CPU Usage in cores**   | Total cluster CPU usage with overlay lines for cluster-wide CPU requests and limits. Helps you see if you are close to over-committing CPU. |
| **Memory Usage in GB**   | Same idea for memory. Watch for the usage line crossing the requests line.                                                                  |
| **PVC total**            | Total storage allocated across all PersistentVolumeClaims.                                                                                  |
| **CPU %**                | Cluster CPU usage as a percentage of total CPU requests.                                                                                    |
| **Mem %**                | Cluster memory usage as a percentage of total memory requests.                                                                              |
| **CPU Usage / Requests** | Per-container, per-namespace CPU usage vs requests — quickly spot the container hogging CPU.                                                |
| **Memory**               | Same per-container, per-namespace view for memory.                                                                                          |
| **PVCs % Used**          | Per-PVC fill percentage. Useful to catch PVCs about to run out of space.                                                                    |

Metric sources: **cAdvisor** (`container_cpu_usage_seconds_total`, `container_memory_working_set_bytes`), **kube-state-metrics** (`kube_pod_container_resource_requests`, `kube_pod_container_resource_limits`), and **kubelet** (`kubelet_volume_stats_*`).

### Kubernetes / Views / Pods

[dashboards/kubernetes-pods.json](https://github.com/MinBZK/mijn-bureau-infra/tree/main/helmfile/apps/observability/charts/observability/dashboards/kubernetes-pods.json) — built by Grafana Labs and designed for `kube-prometheus-stack`. Pick a namespace and a pod from the dropdowns at the top; the dashboard then breaks down that pod's behavior in detail.

What you can drill into:

- **CPU usage** per container, including throttling
- **Memory usage**, working set, RSS, cache
- **Network I/O** in and out of the pod
- **Filesystem I/O** read and write
- **Restart counts** and current status

This is the dashboard to open when a MijnBureau component (Nextcloud, Meet, Keycloak, …) is misbehaving. Use the cluster-level panels in _General overview_ to spot that _something_ is wrong, then use this dashboard to find _which_ pod and _what kind_ of pressure it is under.

Metric sources: **cAdvisor** and **kube-state-metrics** — same set used by the General overview.

To refresh the JSON when a newer revision is published on grafana.com:

```bash
curl -sSL 'https://grafana.com/api/dashboards/15760/revisions/latest/download' \
  > helmfile/apps/observability/charts/observability/dashboards/kubernetes-pods.json
```

### Node Exporter Full

[dashboards/node-exporter-full.json](https://github.com/MinBZK/mijn-bureau-infra/tree/main/helmfile/apps/observability/charts/observability/dashboards/node-exporter-full.json) — the most-installed dashboard on grafana.com. Detailed host-level view, one drop-down per node.

What you can drill into:

- **CPU** per core, per mode (user / system / iowait / idle)
- **Load average** (1m / 5m / 15m)
- **Memory** breakdown — used, cached, buffers, swap
- **Disk I/O** throughput, IOPS, latency per device
- **Network** throughput, drops, errors per interface
- **Filesystem** usage per mount, inode usage
- **File descriptors**, processes, context switches

Open this when _General overview_ / _Pods_ both look healthy but apps still feel slow — the bottleneck may be at the node level (disk saturated, network errors, OOM pressure, etc.).

Metric source: **node-exporter** (`node_*` metrics). Bundled in `kube-prometheus-stack` as a DaemonSet — one pod per node.

To refresh the JSON when a newer revision is published on grafana.com:

```bash
curl -sSL 'https://grafana.com/api/dashboards/1860/revisions/latest/download' \
  > helmfile/apps/observability/charts/observability/dashboards/node-exporter-full.json
```

This dashboard uses an internal datasource picker (no `__inputs`), so it does not require an entry in `metric.grafanaDashboards.datasources` — Grafana will offer a Prometheus datasource dropdown the first time you open it.

---

## Adding a dashboard

The chart auto-discovers every `*.json` file under [dashboards/](https://github.com/MinBZK/mijn-bureau-infra/tree/main/helmfile/apps/observability/charts/observability/dashboards/). To add a new dashboard:

### From the community library

1. Find a dashboard on [grafana.com/grafana/dashboards](https://grafana.com/grafana/dashboards/).
2. Download the JSON. For most dashboards you can use the API directly:

   ```bash
   curl -sSL 'https://grafana.com/api/dashboards/<id>/revisions/latest/download' \
     > helmfile/apps/observability/charts/observability/dashboards/<name>.json
   ```

   Replace `<id>` with the dashboard ID from the URL (e.g. `1860` for Node Exporter Full) and `<name>` with a descriptive slug (this becomes part of the `GrafanaDashboard` resource name).

3. Inspect the JSON for any `__inputs` entries — these are placeholders the dashboard expects you to bind to real datasources:

   ```bash
   jq '.__inputs' helmfile/apps/observability/charts/observability/dashboards/<name>.json
   ```

   Each entry has a `name` (e.g. `DS_PROMETHEUS`). For every such input, add a mapping under `metric.grafanaDashboards.datasources`:

   ```yaml
   datasources:
     - inputName: DS_PROMETHEUS
       datasourceName: Prometheus # name as it appears in your Grafana
   ```

   If the dashboard has no `__inputs` (some use a templated datasource variable instead), no mapping is needed.

4. Re-deploy:

   ```bash
   helmfile -e <environment> apply
   ```

### From an existing Grafana

If an admin has already built a dashboard by hand in your production Grafana, export it instead of starting from scratch:

1. Open the dashboard in Grafana.
2. Click the **Share** button → **Export as code**.
3. **Enable "Export for sharing externally"** — this replaces hardcoded datasource UIDs with portable `${DS_*}` placeholders.
4. Save the file to `dashboards/<name>.json`.
5. Configure the datasource mapping (step 3 above) and re-deploy.

---

## Removing a dashboard

Delete the JSON file from `dashboards/` and re-deploy:

```bash
rm helmfile/apps/observability/charts/observability/dashboards/<name>.json
helmfile -e <environment> apply
```

Helm garbage-collects the corresponding `GrafanaDashboard` resource on the next apply, and the grafana-operator removes the dashboard from Grafana.

---

## Datasource mapping

Exported Grafana dashboards reference datasources via input placeholders (e.g. `${DS_PROMETHEUS}`, `${DS_MIMIR_POC}`) rather than concrete UIDs, so the same JSON works on any Grafana. The grafana-operator resolves each placeholder using the `datasources` block on the `GrafanaDashboard` resource. We populate that block from `metric.grafanaDashboards.datasources`.

```yaml
metric:
  grafanaDashboards:
    datasources:
      - inputName: DS_PROMETHEUS # placeholder in the JSON
        datasourceName: Prometheus # name of the datasource in Grafana
      - inputName: DS_MIMIR_POC
        datasourceName: Mimir
```

The mapping list is shared across every dashboard the chart deploys. Entries that don't match any dashboard's `__inputs` are simply ignored, so it is safe to keep mappings for dashboards you may add later.

---

## Verifying

After `helmfile apply`, check that the operator received the dashboards:

```bash
kubectl get grafanadashboards -n monitoring
# expected:
#   NAME                              ...
#   observability-general-overview    ...
```

Each CR exposes a status condition:

```bash
kubectl describe grafanadashboard observability-general-overview -n monitoring
# Status.Conditions: DashboardSynchronized = True
# Reason: ApplySuccessful
# Message: "Dashboard was successfully applied to N instances"
```

If `NO MATCHING INSTANCES` is `true`, the `instanceSelector` labels do not match any `Grafana` CR — confirm the labels on the Grafana CR match what is configured under `metric.grafanaDashboards.instanceSelector`.

---

## Related

- [Metrics](./metrics.md) — turning on Prometheus scraping and `ServiceMonitor`s per app
- [Logs](./logs.md)
- [Traces](./traces.md)
