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
