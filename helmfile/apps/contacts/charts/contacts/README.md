# Contacts helm chart

Local chart for [suitenumerique/contacts](https://github.com/suitenumerique/contacts), the
shared contacts and address book service from LaSuite.

The chart deploys three workloads from two images:

- `backend`: Django API, gunicorn on port 8000.
- `worker`: Dramatiq worker (`python worker.py`) for imports and trash purging.
- `frontend`: Caddy serving the SPA and proxying `/api`, `/carddav`, `/static`, the admin
  path and the heartbeats to the backend.

Backend paths are intentionally routed through the frontend: Caddy applies the security
headers and the client-IP handling that the backend expects.

Values that differ per environment are rendered from
`helmfile/apps/contacts/values.yaml.gotmpl`.
