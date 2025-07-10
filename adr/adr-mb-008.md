# ADR-MB-008: Helm chart standard

## Status

Accepted

## Context

To improve maintainability, consistency, and scalability of our Helmfile-based infrastructure, we want to standardize the Helm charts used across our projects. Currently, charts may be created ad-hoc using `helm create` or by copying various example templates, leading to inconsistencies and increased maintenance overhead.

## Decision

We will adopt the Bitnami Helm chart template as the standard for creating new Helm charts within our infrastructure. The Bitnami template offers several advantages, including:

- Best practices for chart structure and configuration
- Features such as automatic detection of OpenShift environments
- Built-in support for resource presets and other common patterns
- Strong community support and regular updates

All new product integrations and internal charts will be based on the Bitnami template, unless there is a strong justification for an exception.git s

## Consequences

**Pros:**

- ✅ Consistent and maintainable Helm charts across the organization
- ✅ Leverage community best practices and features
- ✅ Easier onboarding for new team members

**Cons:**

- ❌ Slightly more initial effort required to adapt to the Bitnami template structure
- ❌ May require migration or refactoring of existing charts to align with the new standard
