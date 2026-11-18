# ADR-MB-024: Observability dashboards

## Status

Accepted

## Context

Operators need to answer three questions: is the platform healthy, why did a specific
request fail, and what changed before the incident. MijnBureau deploys around twenty
applications, most with their own metrics endpoints and log formats. If every deployment
assembles its own dashboards, they drift from the components that are actually deployed
and from each other.

Operating a metrics, log and trace backend is an infrastructure responsibility with its
own capacity, retention and compliance requirements. MijnBureau already supports external
Prometheus through `metric.*`, and the documentation states that log aggregation and
tracing are not included.

## Decision

MijnBureau ships **dashboards as code** and relies on the operator's observability stack
for storage and collection.

- Dashboards are stored as JSON in
  `helmfile/apps/observability/charts/observability/dashboards` and deployed as
  `GrafanaDashboard` resources for the grafana-operator, matching the Grafana instance
  selected by `metric.grafanaDashboards.instanceSelector`.
- Metrics collection uses Prometheus. MijnBureau exposes per-application endpoints,
  optional `ServiceMonitor`/`PodMonitor`/`PrometheusRule` resources and a configurable
  scrape namespace (`metric.namespace`, default `monitoring`).
- Logs are written to stdout; shipping them to Loki, Elasticsearch or another backend is
  left to the operator.
- Distributed tracing is not included. Applications that emit traces can be connected to
  an operator-provided Tempo or Jaeger installation.
- Dashboards are reviewed like code; manual edits in Grafana are not the source of truth.

## Consequences

**Pros:**

- ✅ Dashboards follow the deployed components because they live in the same repository.
- ✅ No stateful observability stack is imposed on clusters that already run one.
- ✅ Operators keep control over retention, capacity and data residency.

**Cons:**

- ❌ A Grafana with the grafana-operator and a matching Prometheus are prerequisites for
  the dashboards to be useful.
- ❌ Upstream dashboard JSON changes between releases and needs maintenance.
- ❌ Logs and traces require separate operator tooling; MijnBureau only documents the
  interfaces.
- ❌ Observability is optional, so "works on my cluster" can still mean "unmonitored".
