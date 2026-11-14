# defaultdeny

Creates one `default-deny-ingress` NetworkPolicy per namespace listed in
`values.namespaces`. Inbound traffic to any pod in those namespaces is dropped
unless an application chart's own NetworkPolicy allows it.

Egress is intentionally not restricted here (it would break DNS resolution and
Jobs that reach the Kubernetes API). Apps that need egress control implement
component-level policies in their own charts.

Keep `namespaces` in sync with the enabled applications. It is rendered by the
mijn-bureau defaults from the list of enabled applications and their
`application.<app>.namespace` overrides.

## Parameters

| Name                | Description                                 | Value |
| ------------------- | ------------------------------------------- | ----- |
| `commonLabels`      | Labels on every rendered NetworkPolicy      | `{}`  |
| `commonAnnotations` | Annotations on every rendered NetworkPolicy | `{}`  |
| `namespaces`        | Target namespaces (`name`, opt. `enabled`)  | `[]`  |
