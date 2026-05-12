# Resource Management

This document describes how CPU and memory resources are managed across all MijnBureau applications, including preset definitions, per-app overrides, and custom resource helpers.

## How It Works

Resources are managed through a three-tier system:

1. **Global preset** (`global.resourcesPreset`) - a default preset applied to all applications and their dependencies (PostgreSQL, Redis, MinIO)
2. **Per-app preset** (`global.resourcesPresetPerApp`) - overrides the global preset for specific application components
3. **Explicit resources** (`resource.<app>.<component>`) - overrides everything with exact CPU/memory values
4. **Custom resource helpers** - for apps with hard minimum requirements, a custom `_resources.tpl` enforces a floor regardless of which preset is selected

### Priority Order

When determining resources for a container, the system uses the following priority:

```
1. resource.<app>.<component>    (explicit values, highest priority)
2. resourcesPresetPerApp.<app>   (per-app preset)
3. global.resourcesPreset        (global fallback)
```

## Available Presets

Presets are defined in `helmfile/apps/common/charts/common/templates/_resources.tpl`:

| Preset    | CPU Request | CPU Limit | RAM Request | RAM Limit |
| --------- | ----------- | --------- | ----------- | --------- |
| `none`    | ----        | ----      | ----        | ----      |
| `nano`    | 100m        | 150m      | 128Mi       | 192Mi     |
| `micro`   | 250m        | 375m      | 256Mi       | 384Mi     |
| `small`   | 500m        | 750m      | 512Mi       | 768Mi     |
| `medium`  | 500m        | 750m      | 1024Mi      | 1536Mi    |
| `large`   | 1.0         | 1.5       | 2048Mi      | 3072Mi    |
| `xlarge`  | 1.0         | 3.0       | 3072Mi      | 6144Mi    |
| `2xlarge` | 1.0         | 6.0       | 3072Mi      | 12288Mi   |

All presets include ephemeral storage: 50Mi request / 2Gi limit.

### The `none` option

In addition to the named presets above, `none` is accepted as a special value. It is not a real preset — it is a sentinel that tells the deployment templates to skip rendering the `resources:` block entirely. The container is then created with no CPU/memory requests and no limits. Use this when you intentionally want an app to run without resource constraints

## Global Configuration

The global preset and per-app overrides are configured in `helmfile/environments/default/global.yaml.gotmpl`:

```yaml
global:
  resourcesPreset: "small" # default for all apps

  resourcesPresetPerApp:
    elementweb: "nano"
    synapse: "large"
    grist: "small"
    livekit: "medium"
    nextcloud: "medium"
    meet:
      backend: "micro"
      frontend: "nano"
    docs:
      backend: "micro"
      frontend: "nano"
      celery: "micro"
      yProvider: "micro"
      docspec: "micro"
    drive:
      backend: "micro"
      frontend: "nano"
    conversations:
      backend: "micro"
      frontend: "nano"
    bureaublad:
      backend: "micro"
      frontend: "nano"
```

Explicit per-component resource values can be set in `helmfile/environments/default/resource.yaml.gotmpl`.

## Apps with Custom Resource Helpers

Some applications have hard minimum resource requirements that the standard presets cannot satisfy at lower tiers. These apps have a custom `_resources.tpl` template that enforces a minimum floor, no matter which preset is selected. This prevents misconfiguration from causing crashes.

### ClamAV

- **File**: `helmfile/apps/clamav/charts/clamav/templates/_clamav_resources.tpl`
- **Minimum**: 1 CPU / 3 GiB RAM
- **Reason**: ClamAV needs to load the full virus signature database into memory. Below 3 GiB, the process will be OOM-killed.
- **Floor**: All presets from `nano` to `large` are overridden to 1 CPU / 3Gi request, 2 CPU / 4Gi limit. Only `xlarge` and `2xlarge` scale beyond the floor.
- **Reference**: [ClamAV System Requirements](https://docs.clamav.net/#recommended-system-requirements)

### Collabora Online

- **File**: `helmfile/apps/collabora/charts/collabora/templates/_collabora_resources.tpl`
- **Minimum**: 1 CPU / 512 MiB RAM
- **Reason**: The document rendering engine (LibreOffice-based) requires at least 1 CPU core. Memory scales with concurrent users at approximately 50 MiB per user on top of the base.
- **Floor**: All presets from `nano` to `small` are overridden to 1 CPU / 512Mi request, 2 CPU / 1Gi limit. `medium` and above scale normally.
- **Scaling rule**: ~10 users per CPU thread, ~50 MiB RAM per user + base.

### Keycloak

- **File**: `helmfile/apps/keycloak/charts/keycloak/templates/_keycloak_resources.tpl`
- **Minimum**: 1 vCPU / 1280 MiB RAM
- **Reason**: Keycloak is JVM-based. The JVM allocates 70% of the memory limit for heap plus approximately 300 MiB for non-heap memory. A pod with realm caches and 10,000 sessions needs at least 1250 MiB.
- **Floor**: All presets from `nano` to `medium` are overridden to 1 CPU / 1280Mi request, 2 CPU / 2Gi limit. `large` and above scale normally.
- **Note**: The custom helper only applies to the main Keycloak container. Init containers (`prepareWriteDirs`) and the config CLI job use the standard `common.resources.preset`.
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

| App       | Min CPU | Min RAM  | Mechanism                         | Preset in config |
| --------- | ------- | -------- | --------------------------------- | ---------------- |
| ClamAV    | 1 core  | 3 GiB    | Custom `_clamav_resources.tpl`    | Global fallback  |
| Collabora | 1 core  | 512 MiB  | Custom `_collabora_resources.tpl` | Global fallback  |
| Keycloak  | 1 vCPU  | 1280 MiB | Custom `_keycloak_resources.tpl`  | Global fallback  |
| Ollama    | 2 cores | 8 GiB    | Custom `_ollama_resources.tpl`    | Global fallback  |

These apps are safe at any preset -- the custom helper enforces the minimum regardless.

### Apps with per-app presets

| App           | Component       | Preset   | Min CPU | Min RAM | Notes                                             |
| ------------- | --------------- | -------- | ------- | ------- | ------------------------------------------------- |
| Element Web   | -               | `nano`   | 50m     | 64 MiB  | Static SPA served by nginx                        |
| Synapse       | master + worker | `large`  | 1 core  | 2 GiB   | Matrix homeserver, memory scales with rooms/users |
| Grist         | -               | `small`  | 500m    | 200 MiB | SQLite-based, scales with open documents          |
| LiveKit       | -               | `medium` | 500m    | 512 MiB | WebRTC SFU, scales heavily with participants      |
| Nextcloud     | -               | `medium` | 500m    | 512 MiB | PHP memory limit is 512 MiB per process           |
| Meet          | backend         | `micro`  | 250m    | 256 MiB | Lightweight Django app                            |
| Meet          | frontend        | `nano`   | 100m    | 128 MiB | Static React/Next.js                              |
| Docs          | backend         | `micro`  | 250m    | 256 MiB | Django app                                        |
| Docs          | frontend        | `nano`   | 100m    | 128 MiB | Static React/Next.js                              |
| Docs          | celery          | `micro`  | 250m    | 256 MiB | Background task worker                            |
| Docs          | yProvider       | `micro`  | 250m    | 256 MiB | Yjs collaboration WebSocket server                |
| Docs          | docspec         | `micro`  | 250m    | 256 MiB | Document conversion service                       |
| Drive         | backend         | `micro`  | 250m    | 256 MiB | Django app                                        |
| Drive         | frontend        | `nano`   | 100m    | 128 MiB | Static React/Next.js                              |
| Conversations | backend         | `micro`  | 250m    | 256 MiB | Django app                                        |
| Conversations | frontend        | `nano`   | 100m    | 128 MiB | Static React/Next.js                              |
| Bureaublad    | backend         | `micro`  | 250m    | 256 MiB | Dashboard backend                                 |
| Bureaublad    | frontend        | `nano`   | 100m    | 128 MiB | Dashboard frontend                                |

### Apps using global preset only

| App         | Notes                                                                                                                                                                 |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| OpenProject | External Helm chart, resource presets are managed by the upstream chart. Uses `global.resourcesPreset` directly. Official minimum: 4 CPU / 4 GiB for up to 200 users. |

### Dependencies (PostgreSQL, Redis, MinIO)

All dependency sub-charts (PostgreSQL, Redis, MinIO) use the global `resourcesPreset` value. They do not have per-app overrides. To customize their resources, use explicit values in `resource.yaml.gotmpl`:

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

## How to Override Resources

### Change the global preset for all apps

In your environment values file:

```yaml
global:
  resourcesPreset: "medium"
```

### Change the preset for a specific app component

```yaml
global:
  resourcesPresetPerApp:
    meet:
      backend: "small"
      frontend: "micro"
```

### Set explicit resources (overrides presets)

In `resource.yaml.gotmpl`:

```yaml
resource:
  keycloak:
    keycloak:
      requests:
        cpu: "2"
        memory: "2Gi"
      limits:
        cpu: "4"
        memory: "4Gi"
```

### Disable resource limits entirely

```yaml
global:
  resourcesPreset: "none"
```
