# openzaak

Helm chart for [Open Zaak](https://github.com/open-zaak/open-zaak), the reference implementation
of the Dutch ZGW APIs (Zaken, Documenten, Catalogi, Besluiten).

## Components

- **web** — uwsgi application serving the APIs and admin (default image entrypoint runs DB
  checks, migrations, fixture loading and superuser bootstrap)
- **celery** — Celery worker for background tasks
- **celeryBeat** — Celery beat scheduler (singleton)
- **nginx** — reverse proxy serving uploaded documents via `X-Accel` (`/private-media`)

## Dependencies

- PostgreSQL >= 14 with `postgis` and `pg_trgm` (demo: CloudNativePG postgis cluster)
- Redis compatible cache and Celery broker (demo: Valkey)

## Default catalogus

Set `fixtures.enabled: true` to mount the bundled upstream development fixture
(`files/catalogi.json`, from open-zaak/open-zaak at the chart `appVersion`) at `/app/fixtures`.
The container entrypoint loads it after migrations. Override the content with
`fixtures.catalogus`.
