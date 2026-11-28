---
sidebar_position: 60
---

# Release process

A release is a Git tag. Pushing a tag matching `v*` starts the release workflow,
which renders the deployment, builds the security report, signs the artifacts and
publishes the GitHub release. The documentation site rebuilds from the published
assets afterwards.

## Before you tag

1. **CI is green on `main`.** The release workflow assumes the tagged commit
   renders: `format`, `lint`, `test` and `policy` must pass.
2. **Image versions are the ones you mean to ship.** updatecli opens pull
   requests for new upstream releases; merge them, or consciously skip them.
3. **Secrets are configured.** The release job needs `COSIGN_PRIVATE_KEY` and
   `COSIGN_PASSWORD`. `MIJNBUREAU_MASTER_PASSWORD` and `SOPS_AGE_KEY` are used for
   rendering and fall back to a dummy value, which is enough for the image
   inventory but not for a real deployment test.
4. **The signing key matches the committed public key.**

   ```bash
   cosign public-key --key env://COSIGN_PRIVATE_KEY | diff - cosign.pub
   ```

Optional: generate the report locally first, which takes as long as the CI job.

```bash
pip install -r scripts/requirements.txt
MIJNBUREAU_MASTER_PASSWORD=... python3 scripts/release_report.py \
  --release-tag v1.2.3 --output-dir output/release --jobs 4
open output/release/security/containers.md
```

## Tag

```bash
git tag -s v1.2.3 -m "MijnBureau v1.2.3"
git push origin v1.2.3
```

The tag must match `v*`. The workflow reads the workflow file from the tagged
commit, so a broken workflow definition cannot be fixed by re-running the job -
fix `main` and move the tag.

## What runs, in order

1. **`security-report`** renders `demo` and `production`, takes the union of every
   container image, resolves each tag to a digest, verifies cosign signatures,
   generates CycloneDX and SPDX SBOMs with Syft, and scans the SBOMs with Trivy.
2. **`package-release`** adds the report to `helmfile-<tag>.tar.gz`, creates
   `sbom-<tag>.tar.gz`, signs the tarball, the SBOM bundle, `containers.json`,
   `sbom-index.json` and `SHA256SUMS` with Sigstore bundles, and publishes the
   release.
3. **`deploy-docs`** runs after the release workflow completes, downloads
   `containers.json` for the latest releases and regenerates the
   [releases pages](../releases/index.md).

The report is informational: unsigned or unscannable images are recorded, not
fatal. The job fails only when rendering fails or no image is found.

## After publishing

```bash
TAG=v1.2.3
BASE=https://github.com/MinBZK/mijn-bureau-infra/releases/download/$TAG
curl -LO $BASE/helmfile-$TAG.tar.gz{,.sha256,.sigstore.json}
curl -LO $BASE/containers.json{,.sigstore.json}

cosign verify-blob --key cosign.pub \
  --bundle helmfile-$TAG.tar.gz.sigstore.json helmfile-$TAG.tar.gz
sha256sum -c helmfile-$TAG.tar.gz.sha256
cosign verify-blob --key cosign.pub \
  --bundle containers.json.sigstore.json containers.json
```

Then confirm the release page lists the new tag and that `containers.md` shows
the expected image count and signature summary.

## Do not create the release by hand

Create the tag, not the GitHub release. The workflow creates the release and
attaches the assets; a hand-made release for the same tag has no report, and the
docs build will skip it because there is no `containers.json` to render.
