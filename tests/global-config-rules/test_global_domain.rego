package main
import rego.v1

# Test that global.domain is properly configured in Ingress resources
deny contains msg if {
  input.kind == "Ingress"
  some i
  rule := input.spec.rules[i]
  not endswith(rule.host, ".test-global-domain.example")
  msg := sprintf("Ingress '%s' rule host '%s' does not end with the configured global.domain '.test-global-domain.example' (propagation failed)", [input.metadata.name, rule.host])
}

# Test that global.domain propagates to ingress hostnames across different apps
deny contains msg if {
  input.kind == "Ingress"
  not input.spec.rules
  msg := sprintf("Ingress '%s' has no rules defined - cannot verify global.domain propagation", [input.metadata.name])
}

# Additional check: ensure any ingress has at least one rule with the test domain
deny contains msg if {
  input.kind == "Ingress"
  count(input.spec.rules) > 0
  # Count rules that contain our test domain
  matching_rules := [rule | rule := input.spec.rules[_]; contains(rule.host, "test-global-domain.example")]
  count(matching_rules) == 0
  msg := sprintf("Ingress '%s' does not contain the configured global.domain 'test-global-domain.example' in any rule (propagation failed)", [input.metadata.name])
}
