# Calendars

[Calendars](https://github.com/suitenumerique/calendars) is the calendar and scheduling
application from LaSuite. The chart deploys a Django backend, a Dramatiq worker, a static
React frontend and a SabreDAV CalDAV server.

## Configuration

The chart expects the database, OIDC, SMTP and Redis settings to be provided by the
MijnBureau Helmfile environment. The Django backend proxies CalDAV traffic, so only the
backend and frontend services are exposed through the ingress or HTTPRoute.

Key values:

- `backend.image` - `suitenumerique/calendars-backend` image.
- `worker` - Dramatiq worker that uses the backend image with `python worker.py`.
- `frontend.image` - `suitenumerique/calendars-frontend` image.
- `caldav.image` - `suitenumerique/calendars-caldav` image.
- `caldav.inboundApiKey`, `caldav.outboundApiKey`, `caldav.internalApiKey` - shared API keys
  between Django and the CalDAV server.
- `externalDatabase` - PostgreSQL connection details. Django and the CalDAV server use the
  same database; CalDAV stores its tables in `caldav.dbSchema`.
- `externalRedis` - Valkey/Redis connection used for caching, sessions and Dramatiq.
- `authentication` - OIDC issuer, endpoints and client credentials.
- `smtp` - SMTP settings used for calendar invitations.
- `ingress` - public hostname and TLS settings.

The CalDAV container runs Apache as a non-root user on an unprivileged port. The chart
mounts `ports.conf` and `sabredav.conf` from the chart ConfigMap and initializes the SabreDAV
database schema on startup.

## Parameters

| Parameter           | Description                                                     |
| ------------------- | --------------------------------------------------------------- |
| `global`            | Global parameters shared with subcharts                         |
| `kubeVersion`       | Override Kubernetes version reported by `.Capabilities`         |
| `apiVersions`       | Override Kubernetes API versions reported by `.Capabilities`    |
| `nameOverride`      | String to partially override `common.names.name`                |
| `fullnameOverride`  | String to fully override `common.names.fullname`                |
| `namespaceOverride` | String to fully override `common.names.namespace`               |
| `commonLabels`      | Labels to add to all deployed objects                           |
| `commonAnnotations` | Annotations to add to all deployed objects                      |
| `clusterDomain`     | Kubernetes cluster domain name                                  |
| `extraDeploy`       | Array of extra objects to deploy with the release               |
| `diagnosticMode`    | Diagnostic mode to debug startup issues                         |
| `cluster`           | Cluster routing configuration (populated by shared values)      |
| `backend`           | Django API server (gunicorn)                                    |
| `worker`            | Dramatiq background worker                                      |
| `frontend`          | Static React single-page application served by Caddy            |
| `caldav`            | SabreDAV CalDAV server proxied by the Django backend            |
| `job`               | Database migration jobs                                         |
| `defaultLanguage`   | Default user interface language                                 |
| `messagesChannel`   | Credentials of the service account publishing to Messages       |
| `service`           | Traffic exposure parameters                                     |
| `ingress`           | Public hostname and TLS settings                                |
| `networkPolicy`     | Network policy parameters                                       |
| `serviceAccount`    | Service account parameters                                      |
| `externalRedis`     | Valkey/Redis connection used for caching, sessions and Dramatiq |
| `externalDatabase`  | PostgreSQL connection details                                   |
| `smtp`              | SMTP settings used for calendar invitations                     |
| `authentication`    | OIDC issuer, endpoints and client credentials                   |
| `superuser`         | Initial superuser credentials                                   |
