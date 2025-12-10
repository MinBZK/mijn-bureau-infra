# ADR-MB-011: Container Image Sources

## Status

Accepted (supersedes ADR-MB-008)

## Context

In ADR-MB-008, we adopted the Bitnami Helm chart template as our standard for creating new charts. This decision was based on Bitnami's best practices, features like OpenShift auto-detection, and strong community support. However, as of September 2025, Broadcom (which acquired VMware and its Bitnami assets) has ended its free Bitnami image program.

The key changes from Broadcom include:

- Free Bitnami container images are being deprecated and moved to a legacy archive
- New "Bitnami Secure Images" are available only under commercial license (280 hardened images with SBOM support, CVE patching, enterprise support)
- A limited subset of free, latest-version images remain for development use only
- Helm charts remain available as OCI artifacts on Docker Hub

We have baked Bitnami images into our automated deployment strategies. Without action, our production deployments face potential disruption as deprecated images become unavailable or unpatched. We need to identify alternative container image sources while preserving the proven Bitnami template structure that has served us well.

## Decision

We will move away from Bitnami container images and adopt the following priority order for selecting container images:

1. **Application vendor official images** - Images published and maintained by the application's primary vendor or project
2. **Official Docker Hub images** when vendor images are not available
3. **Case-by-case evaluation** for applications without suitable vendor or official images

**We will preserve the Bitnami Helm chart template structure** as our standard for creating new charts. The template's best practices, features like OpenShift auto-detection, and proven patterns remain valuable regardless of the underlying container image source.

All existing deployments using Bitnami images should be migrated to alternative image sources using this priority order. New charts and deployments must follow this image selection standard.

This decision supersedes ADR-MB-008 while maintaining its core principle: standardized, well-structured Helm charts based on the Bitnami template pattern.

## Consequences

**Pros:**

- ✅ Avoids dependency on Broadcom's commercial licensing model for container images
- ✅ Maintains direct relationship with upstream application vendors and communities
- ✅ Preserves the proven Bitnami template structure and patterns that have served us well
- ✅ Provides flexibility to choose the most appropriate image source for each application
- ✅ Reduces vendor lock-in to a single image provider

**Cons:**

- ❌ Requires migration effort for all existing deployments currently using Bitnami images
- ❌ May lose some configuration conveniences and hardening that Bitnami provided
- ❌ Image quality, maintenance, and update frequency may vary across different vendors
- ❌ Security management and CVE monitoring becomes more critical without Bitnami's centralized patching
- ❌ Each alternative image source must be evaluated and validated before adoption
- ❌ Documentation and runbooks may need updates to reflect new image sources
