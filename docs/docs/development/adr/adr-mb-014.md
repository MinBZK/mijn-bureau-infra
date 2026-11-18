# ADR-MB-014: Routing model

## Status

Accepted (supersedes ADR-MB-010)

## Context

ADR-MB-010 limited the platform to the NGINX Ingress Controller and the HAProxy-based
OpenShift Ingress Controller. Since then:

- Traefik became the primary and default ingress controller.
- Clusters increasingly expose a [Gateway API](https://gateway-api.sigs.k8s.io/) controller
  instead of an Ingress controller; the reference deployment on Fundament uses Envoy
  Gateway.
- Applications are deployed into per-application namespaces, so routes must attach across
  namespaces.

Supporting two routing APIs at once means every reviewed manifest must be valid for the
selected mode, and controller-specific middleware must not leak into Gateway API
deployments.

## Decision

We will support both Ingress and Gateway API, selected per environment with
`cluster.routingMode`:

- `ingress` (default) — Traefik is the default `cluster.ingress.type`; NGINX and
  `haproxy-openshift` remain supported.
- `gateway-api` — MijnBureau renders `Gateway` and `HTTPRoute` resources using
  `cluster.gateway.*`; `cluster.ingress.type` is `none` because there is no Ingress
  controller behind the routes.
- `none` — no routes are rendered.

Controller-specific annotations and middleware are only rendered in `ingress` mode. TLS
issuance is delegated to cert-manager (`cluster.gateway.certManagerClusterIssuer`) when
Gateway API is used.

## Consequences

**Pros:**

- ✅ Existing clusters keep working with Ingress; modern clusters can use Gateway API
  without a second ingress stack.
- ✅ No controller-specific configuration leaks into the other mode.
- ✅ Gateway API gives portable cross-namespace routing and TLS attachment.

**Cons:**

- ❌ Two routing paths to test; CI renders every environment to catch mode-specific errors.
- ❌ Users must pin `cluster.gateway.namespace`; otherwise the Gateway follows the
  kube-context namespace.
- ❌ Gateway API requires its CRDs and a controller before `helmfile apply`.
