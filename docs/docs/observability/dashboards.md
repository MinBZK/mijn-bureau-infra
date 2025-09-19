# Dashboards

MijnBureau does not currently include pre-configured dashboards.

When official dashboards become available, you will need the [Grafana Operator](https://grafana.com/docs/grafana-cloud/developer-resources/infrastructure-as-code/grafana-operator/) installed in your Kubernetes cluster. These dashboards will be published to the [Grafana Dashboards repository](https://grafana.com/grafana/dashboards/) and can be managed via the operator. Alternatively, you can import them directly into Grafana using their dashboard ID.

Until then, you can use community dashboards for the open source tools deployed with MijnBureau, such as:

- [Keycloak](https://grafana.com/grafana/dashboards/?search=keycloak)
- [MinIO](https://grafana.com/grafana/dashboards/?search=minio)
- [Redis](https://grafana.com/grafana/dashboards/?search=redis)
- [PostgreSQL](https://grafana.com/grafana/dashboards/?search=postgres)

Check each tool’s documentation for recommended dashboards and integration instructions.
