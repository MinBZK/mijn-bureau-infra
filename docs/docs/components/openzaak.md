# OpenZaak

MijnBureau supplies an installation of [Open Zaak](https://github.com/open-zaak/open-zaak), a
case and document registration system exposing the Dutch ZGW APIs (Zaken, Documenten, Catalogi,
Besluiten). It runs as a Django application with a Celery worker and beat scheduler, fronted by
an nginx reverse proxy that serves uploaded documents through `X-Accel` redirects.

Open Zaak requires a PostgreSQL database with the `postgis` and `pg_trgm` extensions and a Redis
compatible cache/broker. The demo environment provisions a CloudNativePG postgis cluster and a
Valkey instance automatically; other environments must provide these externally.

## Configuration

To configure this solution, you can override the default settings for your environment. The
defaults are located in the folder `helmfile/environments/default`.

| Name                                | Description                                                 |
| ----------------------------------- | ----------------------------------------------------------- |
| `global.domain`                     | The domain name of your MijnBureau instance                 |
| `global.hostname.openzaak`          | The subdomain of Open Zaak                                  |
| `application.openzaak.enabled`      | Enable Open Zaak                                            |
| `application.openzaak.namespace`    | The Kubernetes namespace name                               |
| `application.openzaak.secretKey`    | Django secret key                                           |
| `application.openzaak.adminUser`    | Django superuser username                                   |
| `database.openzaak.*`               | PostgreSQL connection details (postgis + pg_trgm required)  |
| `cache.openzaak.*`                  | Valkey connection details (cache + Celery broker)           |
| `tls.openzaak.*`                    | TLS settings                                                |
| `pvc.openzaak.*`                    | Storage for PostgreSQL, Valkey and uploaded documents       |
| `resource.openzaak.*`               | Resources for web, celery, celeryBeat, nginx and datastores |
| `autoscaling.horizontal.openzaak.*` | Autoscaling for the web and celery components               |
| `container.openzaak`                | Container image selection                                   |
| `container.cnpg_postgis`            | CloudNativePG postgis image for the demo database cluster   |
| `secret.openzaak.*`                 | Django superuser credentials                                |

## Default catalogus

In the demo environment, the upstream development fixture
([docker/fixtures/catalogi.json](https://github.com/open-zaak/open-zaak/blob/main/docker/fixtures/catalogi.json),
pinned to the deployed version) is loaded automatically on startup. It creates a "Test catalogus"
with example zaaktypen, statustypen, roltypen, resultaattypen, an informatieobjecttype and a
besluittype, plus the feature flag that allows unpublished (concept) types. Other environments
start with an empty installation and create their own catalogi through the admin or the APIs.

## Documents storage

Uploaded documents live on a single-writer (`ReadWriteOnce`) PVC shared between the web, celery
and nginx pods. RWO block volumes can only attach to one node, so these pods carry a required
pod-affinity rule that co-locates them on the same node. Keep replicas at 1 (the default) unless
the media volume is moved to a `ReadWriteMany`-capable provider.

## Notes

- Notifications (the NRC) are not deployed. ZGW consumers that rely on webhooks need an
  [Open Notificaties](https://github.com/open-zaak/open-notificaties) deployment, which is not
  part of MijnBureau.
- The admin interface is available at `https://<hostname>/admin/` with the superuser credentials
  from `secret.openzaak.*`. Admin login is username/password based; there is no OIDC integration
  for end users of the ZGW APIs.

## More information

- [Upstream repository](https://github.com/open-zaak/open-zaak)
- [Documentation](https://open-zaak.readthedocs.io/)
