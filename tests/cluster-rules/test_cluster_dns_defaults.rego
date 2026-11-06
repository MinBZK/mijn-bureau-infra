package main
import rego.v1

# Redis is standalone in this environment, so its policy has no DNS rule.
dns_charts := {
  "bureaublad", "clamav", "collabora", "conversations", "docs", "drive",
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

default_dns(protocol) if {
  some rule in input.spec.egress
  some port in rule.ports
  port.port == 53
  port.protocol == protocol
  not rule.to
}

deny contains msg if {
  dns_policy
  not default_dns("UDP")
  msg := sprintf("NetworkPolicy %q does not allow default DNS on UDP 53", [input.metadata.name])
}

deny contains msg if {
  dns_policy
  input.metadata.labels["app.kubernetes.io/name"] != "minio"
  not default_dns("TCP")
  msg := sprintf("NetworkPolicy %q does not allow default DNS on TCP 53", [input.metadata.name])
}

deny contains msg if {
  dns_policy
  some rule in input.spec.egress
  some port in rule.ports
  port.port == 53
  rule.to
  msg := sprintf("NetworkPolicy %q unexpectedly restricts default DNS destinations", [input.metadata.name])
}
