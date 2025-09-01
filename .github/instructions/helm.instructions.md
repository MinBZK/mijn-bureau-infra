---
applyTo: "helmfile/**/*.yaml"
---

## Helm Chart and Helmfile Instructions

This document provides guidance for creating and managing Helm charts and Helmfiles in the MijnBureau infrastructure repository.

### Guiding Principles

1.  **Start from the Template**: When creating a new application, always start by copying the contents of the `template/` directory. This provides a consistent starting point.
2.  **Leverage Bitnami Charts**: Whenever possible, use existing [Bitnami charts](https://github.com/bitnami/charts) as dependencies for common components like databases (PostgreSQL, Redis) or storage (MinIO). This reduces maintenance overhead. See `helmfile/apps/grist/helmfile-child.yaml.gotmpl` for an example.
3.  **Concise and Focused Charts**: Our custom Helm charts, located in `helmfile/apps/<app-name>/charts/<chart-name>`, should be minimal. They should primarily focus on creating the Kubernetes `Deployment` or `StatefulSet` and any necessary `Service` or `Ingress` objects. Configuration and dependencies are handled by Helmfile.
4.  **Configuration via Helmfile**: All environment-specific configuration, secrets, and dependencies between charts are managed at the Helmfile level. The `values.yaml.gotmpl` files within the charts should expose configuration options, but the actual values are injected from `helmfile/environments/`.

### Creating a New Application

1.  **Copy the Template**:
    - Copy `template/CHART_NAME` to `helmfile/apps/<new-app-name>/charts/<new-app-name>`.
    - Rename the directory and update `Chart.yaml`.
2.  **Create the Helmfile**:
    - Create a `helmfile/apps/<new-app-name>/helmfile-child.yaml.gotmpl`.
    - Follow the pattern in `helmfile/apps/grist/helmfile-child.yaml.gotmpl`.
    - Define any necessary chart dependencies (e.g., a database).
    - Add a release for your new chart.
3.  **Update the Root Helmfile**:
    - Add your new `helmfile-child.yaml.gotmpl` to the root `helmfile.yaml.gotmpl`.
4.  **Configure Values**:
    - The `values.yaml.gotmpl` in your new chart should be based on the template. It uses placeholders like `%%MAIN_CONTAINER%%` which you should replace with the name of your application's main container.
    - The values are designed to be overridden by the Helmfile environment values.
5.  **Keep it Simple**:
    - Avoid complex logic within the Helm chart templates. The goal is to have a simple, reusable chart that is configured externally by Helmfile.
    - Do not include dependencies directly in your chart's `Chart.yaml`. Dependencies are managed in the `helmfile-child.yaml.gotmpl`.

### Example Structure (`grist` application)

- `helmfile/apps/grist/helmfile-child.yaml.gotmpl`: Defines the `grist` release and its dependencies on PostgreSQL, Redis, and MinIO.
- `helmfile/apps/grist/charts/grist/`: The custom chart for the Grist application itself.
- `helmfile/apps/grist/charts/grist/values.yaml.gotmpl`: Exposes configuration for the Grist deployment.
- `helmfile/apps/grist/values-postgresql.yaml.gotmpl`: Values file for the PostgreSQL dependency, used by the Helmfile.
