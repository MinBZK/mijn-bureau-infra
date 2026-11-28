# ADR-MB-023: Air-gapped delivery

## Status

Accepted

## Context

Some MijnBureau deployments run in environments without internet access. A normal
installation pulls Helm charts from public repositories and container images from public
registries at deploy time, which cannot work there. Asking operators to invent their own
mirroring process leads to untested, undocumented procedures.

The repository already needs a container inventory for policy checks, so the same inventory
can drive offline preparation.

## Decision

We will treat air-gapped installation as a supported, scripted path.

- `scripts/airgap_prepare.py` collects every chart and container image referenced by a
  rendered environment into a transferable bundle.
- `scripts/check_container_images.py` verifies that the image inventory is complete and
  resolvable.
- Operators mirror the bundle into an internal registry and chart repository, and override
  `container.<app>.registry` and repository locations in the environment values.
- No chart or image may be fetched at runtime by an application; runtime downloads such as
  Ollama models must be mirrored as well.
- The air-gapped procedure is documented and validated as part of the release process.

## Consequences

**Pros:**

- ✅ Offline installations follow the same values and charts as connected ones.
- ✅ The image inventory doubles as a supply-chain check.
- ✅ Operators get a repeatable bundle instead of a manual checklist.

**Cons:**

- ❌ Bundles are large and must be regenerated for every release.
- ❌ Charts that download models or plugins at startup need extra mirroring work.
- ❌ Digests must be preserved when images are retagged into the internal registry.
