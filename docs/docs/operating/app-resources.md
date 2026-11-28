---
sidebar_position: 50
---

# Per-app resources

Some applications have hard minimum requirements: below them they crash-loop or
silently lose data. This page lists those floors and the applications that
enforce one regardless of the selected preset.

The preset system and how to override it are described in
[Configuration](./configuration.md).

## Apps with Custom Resource Helpers

Some applications have hard minimum resource requirements that the standard presets cannot satisfy at lower tiers. These apps have a custom `_resources.tpl` template that enforces a minimum floor, no matter which preset is selected. This prevents misconfiguration from causing crashes.

### ClamAV

- **File**: `helmfile/apps/clamav/charts/clamav/templates/_clamav_resources.tpl`
- **Minimum**: 1 CPU / 3 GiB RAM
- **Reason**: ClamAV needs to load the full virus signature database into memory. Below 3 GiB, the process will be OOM-killed.
- **Floor**: All presets from `nano` to `large` are overridden to 1 CPU / 3Gi request, 2 CPU / 4Gi limit. Only `xlarge` and `2xlarge` scale beyond the floor.
- **Reference**: [ClamAV System Requirements](https://docs.clamav.net/#recommended-system-requirements)
- The optional ICAP sidecar (`antivirus.icap.enabled`) embeds a second clamd with its own database and is covered by the same preset floor. Set `resource.clamav.icap` to give it static resources instead (keep memory at 4 Gi or more).

### Collabora Online

- **File**: `helmfile/apps/collabora/charts/collabora/templates/_collabora_resources.tpl`
- **Minimum**: 1 CPU / 512 MiB RAM
- **Reason**: The document rendering engine (LibreOffice-based) requires at least 1 CPU core. Memory scales with concurrent users at approximately 50 MiB per user on top of the base.
- **Floor**: All presets from `nano` to `small` are overridden to 1 CPU / 512Mi request, 2 CPU / 1Gi limit. `medium` and above scale normally.
- **Scaling rule**: ~10 users per CPU thread, ~50 MiB RAM per user + base.

### Keycloak

- **File**: `helmfile/apps/keycloak/keycloak.yaml.gotmpl`
- **Minimum**: 1 vCPU / 1280 MiB RAM
- **Reason**: Keycloak is JVM-based. The JVM allocates 70% of the memory limit for heap plus approximately 300 MiB for non-heap memory. A pod with realm caches and 10,000 sessions needs at least 1250 MiB.
- **Floor**: All presets from `nano` to `medium` are overridden to 1 CPU / 1280Mi request, 2 CPU / 2Gi limit. `large` and above scale normally.
- **Note**: The Keycloak floor only applies to the main Keycloak container. The `dbchecker` init container and the config CLI Job use the standard preset mapping.
- **Reference**: [Keycloak Sizing Guide](https://www.keycloak.org/high-availability/multi-cluster/concepts-memory-and-cpu-sizing)

### Ollama

- **File**: `helmfile/apps/ollama/charts/ollama/templates/_ollama_resources.tpl`
- **Minimum**: 2 CPU / 8 GiB RAM
- **Reason**: Ollama loads LLM models entirely into memory. The rule of thumb is ~1 GiB RAM per billion parameters (quantized Q4). A 7B model needs at least 8 GiB. CPU inference is heavily bandwidth-bound and benefits from multiple cores.
- **Floor**: All presets from `nano` to `xlarge` are overridden to 2 CPU / 8Gi request, 4 CPU / 12Gi limit. Only `2xlarge` scales the limits up (8 CPU / 16Gi).
- **Note**: For GPU inference, explicit resources should be set via `resource.ollama` in `resource.yaml.gotmpl` to include GPU device requests.

## Per-App Minimum Requirements

The table below summarizes the minimum resource requirements for each application and what preset or mechanism is used.

### Apps with custom resource helpers (floor enforced)

| App       | Min CPU | Min RAM  | Mechanism                                       | Preset in config |
| --------- | ------- | -------- | ----------------------------------------------- | ---------------- |
| ClamAV    | 1 core  | 3 GiB    | Custom `_clamav_resources.tpl`                  | Global fallback  |
| Collabora | 1 core  | 512 MiB  | Custom `_collabora_resources.tpl`               | `small`          |
| Keycloak  | 1 vCPU  | 1280 MiB | Keycloak preset floor in `keycloak.yaml.gotmpl` | `small`          |
| Ollama    | 2 cores | 8 GiB    | Custom `_ollama_resources.tpl`                  | `small`          |

These apps are safe at any preset -- the custom helper or values mapping enforces the minimum regardless.

### Apps with per-app presets

| App           | Component       | Preset   | Min CPU | Min RAM  | Notes                                             |
| ------------- | --------------- | -------- | ------- | -------- | ------------------------------------------------- |
| Element Web   | -               | `nano`   | 100m    | 128 MiB  | Static SPA served by nginx                        |
| Synapse       | master + worker | `large`  | 1 core  | 2 GiB    | Matrix homeserver, memory scales with rooms/users |
| LiveKit       | -               | `medium` | 500m    | 1024 MiB | WebRTC SFU, scales heavily with participants      |
| LiveKit       | egress          | `xlarge` | 1 core  | 3 GiB    | Recording; ~4 CPU per composite recording         |
| Nextcloud     | -               | `medium` | 500m    | 1024 MiB | PHP memory limit is 512 MiB per process           |
| Meet          | backend         | `micro`  | 250m    | 256 MiB  | Lightweight Django app                            |
| Meet          | frontend        | `nano`   | 100m    | 128 MiB  | Static React/Next.js                              |
| Meet          | celeryBackend   | `micro`  | 250m    | 256 MiB  | Celery worker                                     |
| Meet          | agents          | `micro`  | 250m    | 256 MiB  | LiveKit metadata/subtitles agents                 |
| Meet          | summary         | `micro`  | 250m    | 256 MiB  | Transcription/summary workers                     |
| Docs          | backend         | `micro`  | 250m    | 256 MiB  | Django app                                        |
| Docs          | frontend        | `nano`   | 100m    | 128 MiB  | Static React/Next.js                              |
| Docs          | celery          | `micro`  | 250m    | 256 MiB  | Background task worker                            |
| Docs          | yProvider       | `micro`  | 250m    | 256 MiB  | Yjs collaboration WebSocket server                |
| Docs          | docspec         | `micro`  | 250m    | 256 MiB  | Document conversion service                       |
| Drive         | backend         | `micro`  | 250m    | 256 MiB  | Django app                                        |
| Drive         | frontend        | `nano`   | 100m    | 128 MiB  | Static React/Next.js                              |
| Conversations | backend         | `micro`  | 250m    | 256 MiB  | Django app                                        |
| Conversations | frontend        | `nano`   | 100m    | 128 MiB  | Static React/Next.js                              |
| Conversations | celery          | `micro`  | 250m    | 256 MiB  | Celery worker                                     |
| Conversations | celeryBeat      | `micro`  | 250m    | 256 MiB  | Celery beat scheduler                             |
| Dictaphone    | backend         | `micro`  | 250m    | 256 MiB  | Django app                                        |
| Dictaphone    | frontend        | `nano`   | 100m    | 128 MiB  | Static frontend                                   |
| Dictaphone    | celery          | `micro`  | 250m    | 256 MiB  | Celery worker                                     |
| Dictaphone    | audioExtractor  | `micro`  | 250m    | 256 MiB  | Audio extraction worker                           |
| Dictaphone    | s3Gateway       | `nano`   | 100m    | 128 MiB  | S3 gateway sidecar                                |
| Projects      | -               | `micro`  | 250m    | 256 MiB  | Project management app                            |
| Bureaublad    | backend         | `micro`  | 250m    | 256 MiB  | Dashboard backend                                 |
| Bureaublad    | frontend        | `nano`   | 100m    | 128 MiB  | Dashboard frontend                                |
| Calendars     | backend         | `micro`  | 250m    | 256 MiB  | Django app                                        |
| Calendars     | worker          | `micro`  | 250m    | 256 MiB  | Dramatiq background worker                        |
| Calendars     | frontend        | `nano`   | 100m    | 128 MiB  | Static React/Vite                                 |
| Calendars     | caldav          | `micro`  | 250m    | 256 MiB  | SabreDAV PHP server                               |
| Messages      | backend         | `micro`  | 250m    | 256 MiB  | Django app and email API                          |
| Messages      | worker          | `micro`  | 250m    | 256 MiB  | Celery worker and beat scheduler                  |
| Messages      | frontend        | `nano`   | 100m    | 128 MiB  | Static React/Vite                                 |
| Messages      | mta             | `small`  | 500m    | 512 MiB  | Inbound SMTP server                               |
| Messages      | opensearch      | `medium` | 500m    | 1024 MiB | Full-text search index                            |

### Dependencies (PostgreSQL, Valkey, object store, OpenSearch)

PostgreSQL is provided by CloudNativePG and uses explicit resources from `resource.<app>.postgresql`.
Valkey uses `resource.<app>.valkey` when set, otherwise the global `resourcesPreset`. The object
store uses the global `resourcesPreset` value. OpenSearch uses `resource.<app>.opensearch` when set,
otherwise the per-app preset. To customize PostgreSQL resources, use explicit values in
`resource.yaml.gotmpl`:

```yaml
resource:
  nextcloud:
    postgresql:
      requests:
        cpu: "500m"
        memory: "512Mi"
      limits:
        cpu: "1"
        memory: "1Gi"
```
