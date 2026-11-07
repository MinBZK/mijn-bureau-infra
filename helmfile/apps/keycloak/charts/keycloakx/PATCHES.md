# Local patches

Vendored from `codecentric/keycloakx` chart `7.4.0` (appVersion `26.8.1`).

Local changes:

- Added the Keycloak management port `9000` to both ingress rule port lists in
  `templates/networkpolicy.yaml`, so Prometheus can scrape the metrics/health
  endpoint from the monitoring namespace and the ServiceMonitor works.
- Added `app.kubernetes.io/version` to the StatefulSet pod template labels in
  `templates/statefulset.yaml`, matching the repository's policy requirement
  without duplicating the label on every chart resource.
- Removed trailing whitespace from `templates/hpa.yaml`.

No runtime behavior of the chart was changed.
