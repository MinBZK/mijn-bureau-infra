---
sidebar_position: 80
---

# Supply chain and release reports

Every release tag publishes a security report next to the deployment tarball. The
report records exactly which container images the release deploys, which digests
they resolve to, whether they carry a cosign signature, and which known
vulnerabilities the image contents contain.

The release workflow renders the `demo` and `production` environments, takes the
union of all container images (including sidecars, init containers and Job
images), and describes each image once. The report is **informational**: unsigned
or unscannable images are recorded, never used to block a release.

## Release artifacts

| Asset                                 | Contents                                                                         |
| ------------------------------------- | -------------------------------------------------------------------------------- |
| `helmfile-<tag>.tar.gz`               | The Helmfile deployment, plus `cosign.pub` and the `security/` report directory. |
| `helmfile-<tag>.tar.gz.sha256`        | SHA-256 checksum of the tarball.                                                 |
| `helmfile-<tag>.tar.gz.sigstore.json` | Cosign bundle that signs the tarball.                                            |
| `sbom-<tag>.tar.gz`                   | All CycloneDX and SPDX SBOMs for this release.                                   |
| `containers.json`                     | Machine-readable image inventory.                                                |
| `containers.md`                       | The same inventory as a table.                                                   |
| `images.lock.yaml`                    | Tag to digest lock for this release.                                             |
| `signatures.json`                     | Cosign verification result per image.                                            |
| `sbom-index.json`                     | SBOM file names with their checksums.                                            |
| `cve.json`                            | Trivy findings per image, grouped by severity.                                   |
| `SHA256SUMS`                          | Checksums of every file in `security/`.                                          |
| `*.sigstore.json`                     | Cosign bundles for `containers.json`, `sbom-index.json` and `SHA256SUMS`.        |

The [releases overview](https://minbzk.github.io/mijn-bureau-infra/docs/releases)
is generated from `containers.json` at build time, so the documentation always
shows the published inventory.

## What the inventory records

`containers.json` contains one entry per image with:

- `image`, `tag` and `digest` - the tag is for humans, the digest is the version
  that actually runs. `digest` is the multi-architecture index digest;
  `platform_digest` is the `linux/amd64` manifest digest used for the SBOM.
- `environments`, `components` and `usages` - where the image is used, so a
  reader can map an image back to a chart and namespace.
- `mutable_tag` - `true` for tags such as `main` or `latest`, which can change
  without a Git change. These images are only reproducible through their digest.
- `signature` - the cosign verification result.
- `sbom` - file name, SHA-256 checksum and size per SBOM format.
- `cve` - vulnerability counters per severity and the individual findings.

### Signature status

| Status                  | Meaning                                                                                                |
| ----------------------- | ------------------------------------------------------------------------------------------------------ |
| `verified (keyless)`    | The digest carries a Sigstore keyless signature from a Fulcio certificate, logged in Rekor.            |
| `verified (key)`        | The digest was signed with the release key in `cosign.pub`.                                            |
| `unsigned`              | No cosign signature is published for the digest.                                                       |
| `signed (unverifiable)` | A signature exists, but not from a Fulcio certificate or `cosign.pub`, so it cannot be validated here. |
| `error`                 | The registry or transparency log could not be queried.                                                 |

Most upstream images - Docker Official Images, Kubernetes images, LaSuite images -
are not cosign-signed. Signature verification is therefore report-only. It tells
you which images carry verifiable provenance today; it does not claim that the
others are untrustworthy.

## Verify a release

Verification uses the release public key, which is kept in
[`cosign.pub`](https://github.com/MinBZK/mijn-bureau-infra/blob/main/cosign.pub).

```bash
TAG=v1.2.3
BASE=https://github.com/MinBZK/mijn-bureau-infra/releases/download/${TAG}

curl -LO ${BASE}/helmfile-${TAG}.tar.gz
curl -LO ${BASE}/helmfile-${TAG}.tar.gz.sha256
curl -LO ${BASE}/helmfile-${TAG}.tar.gz.sigstore.json
curl -LO ${BASE}/SHA256SUMS.sigstore.json
curl -LO ${BASE}/containers.json
curl -LO ${BASE}/containers.json.sigstore.json
curl -LO https://raw.githubusercontent.com/MinBZK/mijn-bureau-infra/main/cosign.pub

# 1. The tarball is signed by the release key.
cosign verify-blob --key cosign.pub \
  --bundle helmfile-${TAG}.tar.gz.sigstore.json helmfile-${TAG}.tar.gz

# 2. The tarball matches its published checksum.
sha256sum -c helmfile-${TAG}.tar.gz.sha256

# 3. The inventory is signed by the release key.
cosign verify-blob --key cosign.pub \
  --bundle containers.json.sigstore.json containers.json

# 4. Every file inside the report matches its checksum.
tar -xzf helmfile-${TAG}.tar.gz security/
sha256sum -c security/SHA256SUMS --ignore-missing
```

Cosign prints the verified identity and transparency log entry. A non-zero exit
code means the artifact was modified or signed with another key.

Because `containers.json` is signed and lists every image digest, a single
signature covers the entire release: verifying it is sufficient to trust the
digests, SBOM checksums and vulnerability data in the report.

### Verify an individual image

When an upstream project publishes its own signature, verify it directly:

```bash
cosign verify \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github\.com/<org>/<repo>/\.github/workflows/.*$' \
  registry-1.docker.io/<org>/<image>@<digest>
```

Or against the MijnBureau release key:

```bash
cosign verify --key cosign.pub registry-1.docker.io/<org>/<image>@<digest>
```

## Vulnerabilities

CVE data comes from [Trivy](https://trivy.dev) scanning the CycloneDX SBOM of each
image digest. The report lists findings per severity (`critical`, `high`,
`medium`, `low`) with the package, installed version and fixed version.

Keep in mind:

- A finding is not proof of exploitability. Reachability and configuration
  determine the real risk.
- Images are scanned at release time. New CVEs are published daily, so scan the
  SBOMs yourself before deploying an older release.
- `fixable` counts findings for which an upstream fixed version exists. Distroless
  and scratch-based images usually show fewer findings because they contain fewer
  packages.

To rescan a release without pulling images:

```bash
tar -xzf sbom-${TAG}.tar.gz
trivy sbom sbom/<image>-<tag>-<digest>.cdx.json
```

## Regenerate a report locally

Rendering requires `helmfile`, `skopeo`, `syft`, `trivy`, `cosign` and Python with
PyYAML installed.

```bash
pip install -r scripts/requirements.txt
export MIJNBUREAU_MASTER_PASSWORD=...   # required to render the manifests

python3 scripts/release_report.py \
  --release-tag v1.2.3 \
  --output-dir output/release \
  --jobs 4
```

The report is written to `output/release/security`. Useful flags:

- `--environment demo --environment production` selects the environments
  (default: both).
- `--platform linux/arm64` changes the digest and SBOM platform.
- `--skip-sbom`, `--skip-scan`, `--skip-signatures` skip expensive steps.
- `--only <regex>` processes a subset of images, which is useful for testing.
- `--skip-render` reuses `output/release/render` instead of rendering again.

## Known limitations

- Digest pinning is not enforced yet. `policy/image-digest.rego` warns about
  images without a digest, and [ADR-MB-019](../architecture/adr/adr-mb-019.md)
  describes the migration. Until then, use `images.lock.yaml` from the release to
  pin images.
- Images with a mutable tag (`find:main`) are only reproducible through the
  recorded digest.
- Sigstore keyless verification accepts any Fulcio identity, so the report states
  _that_ an image is signed, not that a specific team signed it. Add per-image
  identity expectations when a project publishes them.
