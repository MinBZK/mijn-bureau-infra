# ADR-MB-013: Load-testing tool

## Status

Proposed

## Context

MijnBureau composes around fifteen deployed applications. We have no consistent way to verify
that any of them holds up under realistic load before the next release. Before adding scenarios
for specific applications, we need to standardise on a single tool.

Per [ADR-MB-012](./adr-mb-012.md), we evaluate partner-stack options first. OpenDesk publishes a
k6-based load-testing harness on `opencode.de` (under
`bmi/opendesk/components/platform-development/load-tests`). We adopt the same underlying tool
(k6 + k6-operator) but package it differently — see the Decision section for the rationale.
LaSuite does not publish anything in this space. We require real-time correlation between
synthetic load and cluster metrics in Grafana, a Helm-deployable Kubernetes operator, and
scenario scripts a small mixed team can read and review.

## Decision

We will use **k6 with the k6-operator**.

We choose k6 over the other realistic candidates because:

- **Real-time metrics during a run.** k6 streams measurements to Prometheus as the run proceeds.
  Gatling Open Source does not stream to a time-series backend at all — its OSS reporting model
  is a post-run HTML summary, and live monitoring is a Gatling Enterprise feature. The
  community `gatling-operator` reflects this: its value proposition is automated post-run report
  uploads, not live observability. For correlating load with cluster behaviour while a run is
  happening, Gatling OSS does not meet the requirement.
- **Same vendor as our observability stack.** Grafana Labs maintains k6, k6-operator, and the
  Grafana stack we already deploy. The published k6 Prometheus dashboard drops into the existing
  Grafana with no bridging code.
- **First-party Kubernetes operator.** `grafana/k6-operator` ships native `TestRun` CRDs and a
  Helm chart, maintained by the same vendor. `gatling-operator` is community-maintained (st-tech)
  and capable, but introduces a separate maintenance dependency.
- **Reviewable scenarios.** k6 supports TypeScript natively since v0.57. A WebDAV upload scenario
  is around thirty lines, type-checked against `@types/k6`, with no JVM toolchain and no Python
  class hierarchy to navigate.

The runner-up is **Locust** with the community `locust-k8s-operator`. It is Apache-2.0, actively
maintained, ships a Helm chart, and exposes live aggregates via a sidecar Prometheus exporter
with no experimental flags. The choice between k6 and Locust here is partly judgement: k6 wins
on first-party stack alignment, Locust wins on a stricter "no experimental output" posture. Every
other candidate we examined (JMeter, Vegeta, Artillery, the official `locustio/k8s-operator` at
v0.1.6) is meaningfully weaker on either Kubernetes-native operation, real-time metrics, or
maintenance maturity.

The k6-operator is installed cluster-wide once per cluster, outside helmfile.

The harness — chart, scenarios, `TestRun` templates, CI — lives in
[mijn-bureau-loadtest](https://github.com/MinBZK/mijn-bureau-loadtest), separate from this
deployment repo. The harness exercises a deployed MijnBureau cluster; its lifecycle is
independent of platform deployment. This ADR records the tool-choice decision; the linked repo
holds the implementation.

OpenDesk packages this differently — raw `TestRun` manifests, GitLab CI, Univention UDM for user
seeding. Our stack is Helm + GitHub Actions + Keycloak, so we package the same tool to fit our
conventions rather than adopting theirs. Scripts and operational patterns stay transferable; the
deployment harness does not.

## Consequences

**Pros:**

- ✅ Synthetic load metrics and cluster metrics share one Grafana instance and one timeline.
  Reading the load against cluster reaction does not require bridging exporters or stitching
  separate reports.
- ✅ Scenarios are TypeScript and run unchanged on a developer workstation and inside the
  cluster, with type-checking against `@types/k6`. No JVM toolchain, no separate compile step.
- ✅ k6, k6-operator, and the Grafana stack share a single upstream maintainer. Upgrades and
  compatibility live in one project.
- ✅ Same tool family as OpenDesk's harness. Scripts and operational learnings transfer between
  teams; we benefit from upstream patterns OpenDesk has already validated.

**Cons:**

- ❌ k6's Prometheus remote-write output is officially labelled experimental. It is in
  widespread production use and stable in practice, but the upstream reserves the right to
  introduce breaking changes — pin the k6 image version and audit at upgrade time.
- ❌ k6's Prometheus output aggregates trend metrics at millisecond precision, not per-request
  raw values. Acceptable for a breaking-point test where the cliff is the headline event;
  insufficient if a future scenario requires raw per-request percentiles.
- ❌ Adopting k6 standardises on a Grafana Labs product. A future licence or direction change at
  Grafana Labs carries the cost of a migration.
- ❌ Partner alignment is at the tool level only. We do not consume OpenDesk's chart, CI, or
  user-seeding flow — those are tied to their packaging and identity stack. Cross-team reuse is
  limited to scripts and operational patterns, not the deployment harness itself.
