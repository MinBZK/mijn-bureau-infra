package main
import rego.v1

deny contains msg if {
  input.kind in {"Ingress"}
  some i
  rule := input.spec.rules[i]
  not endswith(rule.host, ".mijnbureau.nl")
  msg := ".Values.global.domain not properly configured in Ingress"
}
