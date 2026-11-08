# Calendars

MijnBureau supplies an installation of [Calendars](https://github.com/suitenumerique/calendars),
the calendar and scheduling application from LaSuite. It combines a Django REST API, a React
single-page frontend and a SabreDAV CalDAV server. The CalDAV server stores calendar data in
PostgreSQL and the Django backend proxies CalDAV requests, so desktop and mobile calendar
clients can synchronize through the same hostname as the web application.

## Configuration

To configure this solution, you can override the default settings for your environment. The
defaults are located in the folder `helmfile/environments/default`.

| Name                                 | Description                                                     |
| ------------------------------------ | --------------------------------------------------------------- |
| `global.domain`                      | The domain name of your MijnBureau instance                     |
| `global.hostname.calendars`          | The subdomain of the Calendars frontend and CalDAV API          |
| `application.calendars.enabled`      | Enable Calendars                                                |
| `application.calendars.namespace`    | The Kubernetes namespace name                                   |
| `application.calendars.secretKey`    | Django secret key                                               |
| `application.calendars.saltKey`      | Salt used to encrypt sensitive fields                           |
| `application.calendars.caldav.*`     | Internal CalDAV API keys                                        |
| `authentication.client.calendars.*`  | OIDC client credentials                                         |
| `database.calendars.*`               | PostgreSQL connection details                                   |
| `cache.calendars.*`                  | Valkey connection details                                       |
| `tls.calendars.*`                    | TLS settings                                                    |
| `pvc.calendars.*`                    | Storage requirements for PostgreSQL and Valkey                  |
| `resource.calendars.*`               | Resources for each component                                    |
| `autoscaling.horizontal.calendars.*` | Autoscaling for the backend, worker, frontend and CalDAV server |
| `container.calendars_*`              | Container image selection                                       |
| `secret.calendars.*`                 | Django admin credentials                                        |

## Components

| Component | Description                                                       |
| --------- | ----------------------------------------------------------------- |
| Backend   | Django REST API, OIDC authentication and CalDAV proxy (gunicorn)  |
| Worker    | Dramatiq background worker for imports, synchronization and email |
| Frontend  | React single-page application served by Caddy                     |
| CalDAV    | SabreDAV server that stores calendars and events in PostgreSQL    |

The backend and worker share a PostgreSQL database. The CalDAV server stores its tables in
the `sabre` schema of the same database and initializes the schema on startup.

## CalDAV clients

Point CalDAV clients at:

```text
https://<calendars-hostname>/.well-known/caldav
```

Clients authenticate with CalDAV channel credentials created from the application.
The Django backend validates those credentials and forwards requests to the internal
CalDAV server. The web application itself signs in through Keycloak.

## More information

- [Upstream repository](https://github.com/suitenumerique/calendars)
- [Architecture documentation](https://github.com/suitenumerique/calendars/blob/main/docs/architecture.md)
