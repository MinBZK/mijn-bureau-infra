---
sidebar_position: 10
---

# Observability

MijnBureau exposes metrics, logs and traces per component; a cluster-wide
Prometheus, log store and trace backend are expected to already exist.

| Signal     | Page                          | What you get                                              |
| ---------- | ----------------------------- | --------------------------------------------------------- |
| Metrics    | [Metrics](./metrics.md)       | Prometheus endpoints from the applications and datastores |
| Dashboards | [Dashboards](./dashboards.md) | Per-component Grafana dashboards                          |
| Logs       | [Logs](./logs.md)             | Container and application logs                            |
| Traces     | [Traces](./traces.md)         | Distributed traces for the AI and document services       |

Start with metrics and alerting on the platform components - CNPG replication and
backup age, Keycloak availability, certificate expiry - before adding
per-application dashboards.
