# ADR-MB-009: resource labels

## Status

Accepted

## Context

Consistent labeling of Kubernetes resources is essential for effective management, automation, and observability. Labels enable us to select, organize, and operate on groups of resources efficiently. Without a standard, labels can become fragmented, making it harder to query, monitor, and automate workloads.

## Decision

We will adopt the [Kubernetes recommended common labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/) for all resources managed by our infrastructure. These labels include, but are not limited to:

- `app.kubernetes.io/name`
- `app.kubernetes.io/instance`
- `app.kubernetes.io/version`
- `app.kubernetes.io/component`
- `app.kubernetes.io/part-of`
- `app.kubernetes.io/managed-by`

All new and existing resources should use these labels where applicable. Additional custom labels may be added as needed, but must not conflict with the recommended set.

## Consequences

**Pros:**

- ✅ Enables consistent querying, monitoring, and automation across all environments.
- ✅ Aligns with Kubernetes community best practices.
- ✅ Simplifies troubleshooting and resource management.
- ✅ Facilitates integration with third-party tools and dashboards.

**Cons:**

- ❌ Requires updating existing resources to conform to the new labeling standard.
- ❌ May introduce minor overhead in resource definition and review.

By following this standard, we ensure our Kubernetes resources are easier to manage, scale, and integrate with the broader ecosystem.
