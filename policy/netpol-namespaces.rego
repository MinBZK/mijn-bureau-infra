package main

import rego.v1

# Best-practice guardrail for namespace-scoped NetworkPolicy peers.
#
# A NetworkPolicy peer that selects only namespaces ("namespaceSelector"
# without "podSelector") lets every pod in the selected namespaces talk to the
# protected pods. Prefer scoping also a podSelector (e.g. the backing
# component's app.kubernetes.io/name labels), or use ingressNSMatchLabels with
# well-known namesspace labels (kubernetes.io/metadata.name).
#
# Not denied: plenty of environment-managed policies (e.g. egress to a shared
# Keycloak namespace, CNPG clients) intentionally trust a whole namespace.

warn contains msg if {
	input.kind == "NetworkPolicy"
	some i, j
	peer := input.spec.ingress[i].from[j]
	peer.namespaceSelector
	not peer.podSelector
	msg := sprintf("NetworkPolicy '%s' in namespace '%s' has an ingress rule selecting whole namespaces without a podSelector (broader than required)", [input.metadata.name, input.metadata.namespace])
}

warn contains msg if {
	input.kind == "NetworkPolicy"
	some i, j
	peer := input.spec.egress[i].to[j]
	peer.namespaceSelector
	not peer.podSelector
	msg := sprintf("NetworkPolicy '%s' in namespace '%s' has an egress rule selecting whole namespaces without a podSelector (broader than required)", [input.metadata.name, input.metadata.namespace])
}
