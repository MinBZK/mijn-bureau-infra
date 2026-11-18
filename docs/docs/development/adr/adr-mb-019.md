# ADR-MB-019: Container supply chain

## Status

Accepted (amends ADR-MB-011)

## Context

ADR-MB-011 selects image sources but says nothing about how images are pinned, verified or
updated. Images referenced by a mutable tag can change without any change in Git, and a
`:latest` tag makes a rollout unreproducible. MijnBureau already runs policy checks with
Conftest, and container tags are maintained by updatecli, so the guardrails can be enforced
in CI rather than by convention.

## Decision

We will treat container image references as part of the reviewed configuration.

- `:latest` is denied unconditionally by `policy/image-digest.rego`.
- Images without a `@sha256:` digest produce a warning; the target state is digest pinning
  for every image.
- For non-digest images, `policy/image.rego` requires `imagePullPolicy: Always`.
- Image updates are proposed by updatecli (`.github/workflows/container-update.yaml`), not
  applied manually.
- `scripts/check_container_images.py` verifies that referenced images resolve.
- Images from `bitnamilegacy/*` remain a recorded exception until MinIO and its helpers are
  migrated to vendor images.

## Consequences

**Pros:**

- ✅ A rendered manifest identifies exactly which image will run.
- ✅ Tag drift becomes visible as a policy warning or a failed CI run.
- ✅ Updates are reviewable pull requests with a changelog.

**Cons:**

- ❌ Digest bumps are noisier than tag bumps and touch many files.
- ❌ Charts that hardcode tags need overrides to satisfy the policy.
- ❌ The remaining Bitnami legacy images are unpatched and must be migrated before they
  disappear.
