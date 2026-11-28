---
sidebar_position: 40
---

# Configuration

How CPU and memory are managed across MijnBureau: the global preset, per-app
presets, explicit values, and the order in which they apply.

Per-app minimum requirements and the applications with a custom resource floor
are on [Per-app resources](./app-resources.md).

## How It Works

Resources are managed through four mechanisms:

1. **Global preset** (`global.resourcesPreset`) - a default preset applied to all applications and their dependencies (PostgreSQL, Valkey, object store)
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

(The custom resource helpers sit outside this chain — they always enforce their minimum floor.)

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
    collabora: "small"
    elementweb: "nano"
    keycloak: "small"
    ollama: "small"
    synapse: "large"
    livekit: "medium"
    livekitEgress: "xlarge"
    meet:
      backend: "micro"
      frontend: "nano"
      celeryBackend: "micro"
      agents: "micro"
      summary: "micro"
    nextcloud: "medium"
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
      celery: "micro"
      celeryBeat: "micro"
    projects: "micro"
    calendars:
      backend: "micro"
      worker: "micro"
      frontend: "nano"
      caldav: "micro"
    dictaphone:
      backend: "micro"
      frontend: "nano"
      celery: "micro"
      audioExtractor: "micro"
      s3Gateway: "nano"
    messages:
      backend: "micro"
      worker: "micro"
      frontend: "nano"
      mta: "small"
      opensearch: "medium"
    bureaublad:
      backend: "micro"
      frontend: "nano"
```

Explicit per-component resource values can be set in `helmfile/environments/default/resource.yaml.gotmpl`.

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
