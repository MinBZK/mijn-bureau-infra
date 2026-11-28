# ADR-MB-017: Default-deny network isolation

## Status

Accepted

## Context

MijnBureau deploys applications from many upstream projects, each with its own assumptions
about network access. Some charts expect unrestricted in-cluster traffic; others expect
ingress from an ingress controller. A compromise in one application should not give it
free access to the databases and caches of every other application.

Kubernetes network policies are namespaced, so a baseline that applies to all deployments
must be generated per application namespace rather than shipped once.

## Decision

We will enforce a default-deny ingress baseline for every enabled application namespace.

- When `cluster.networkPolicy.defaultDeny.enabled` is true (the default), the `defaultdeny`
  release creates a `default-deny-ingress` NetworkPolicy in every enabled application
  namespace that sets `application.<app>.namespace`.
- The baseline allows traffic only from pods in the same namespace. Cross-application and
  ingress traffic must be granted explicitly by the application's own chart, for example
  with `allowExternal` or namespace selector labels.
- Charts and values that add allowances must select pods, not whole namespaces. The policy
  `policy/netpol-namespaces.rego` warns when a NetworkPolicy selects an entire namespace.
- Namespace selectors rely on the `kubernetes.io/metadata.name` label, which standard
  Kubernetes and Haven clusters set automatically.

## Consequences

**Pros:**

- ✅ A compromised application cannot reach unrelated databases or caches by default.
- ✅ The baseline is visible in Git and tested by Conftest, not configured per cluster.
- ✅ Applications must document their network dependencies instead of relying on open
  traffic.

**Cons:**

- ❌ New integrations can break silently until an allow policy is added.
- ❌ Egress is deliberately left open; this ADR only covers ingress.
- ❌ Clusters that do not label namespaces require manual selector adjustments.
