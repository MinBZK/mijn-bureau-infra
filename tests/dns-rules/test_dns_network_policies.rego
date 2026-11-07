package main
import rego.v1

# Redis in these Helmfile environments is standalone and has no DNS rule.
# Policies allowing all egress also intentionally have no individual DNS rule.
dns_charts := {
  "bureaublad", "clamav", "collabora", "conversations", "dictaphone", "docs", "drive",
  "element-web", "keycloak", "livekit-server", "meet", "minio", "nextcloud",
  "nginx", "ollama", "postgresql", "projects", "synapse",
}

allows_all_egress if {
  some rule in object.get(input.spec, "egress", [])
  rule == {}
}

dns_policy if {
  input.kind == "NetworkPolicy"
  object.get(input.metadata.labels, "app.kubernetes.io/name", "") in dns_charts
  not allows_all_egress
}

external_dns(protocol) if {
  some rule in input.spec.egress
  some port in rule.ports
  port.port == 1053
  port.protocol == protocol
  not rule.to
}

internal_dns(protocol) if {
  some rule in input.spec.egress
  some port in rule.ports
  port.port == 5353
  port.protocol == protocol
  count(rule.to) == 1
  rule.to[0].namespaceSelector.matchLabels["kubernetes.io/metadata.name"] == "test-dns"
}

deny contains msg if {
  dns_policy
  not external_dns("UDP")
  msg := sprintf("NetworkPolicy %q does not allow external DNS on UDP 1053", [input.metadata.name])
}

deny contains msg if {
  dns_policy
  input.metadata.labels["app.kubernetes.io/name"] != "minio"
  not external_dns("TCP")
  msg := sprintf("NetworkPolicy %q does not allow external DNS on TCP 1053", [input.metadata.name])
}

deny contains msg if {
  dns_policy
  not internal_dns("UDP")
  msg := sprintf("NetworkPolicy %q does not allow internal DNS on UDP 5353 in test-dns", [input.metadata.name])
}

deny contains msg if {
  dns_policy
  input.metadata.labels["app.kubernetes.io/name"] != "minio"
  not internal_dns("TCP")
  msg := sprintf("NetworkPolicy %q does not allow internal DNS on TCP 5353 in test-dns", [input.metadata.name])
}

deny contains msg if {
  dns_policy
  some rule in input.spec.egress
  some port in rule.ports
  port.port == 53
  msg := sprintf("NetworkPolicy %q still allows the old DNS port 53", [input.metadata.name])
}
