package main
import rego.v1

deny contains msg if {
  input.kind == "HTTPRoute"
  not input.spec.parentRefs
  msg := sprintf("HTTPRoute '%s' is missing spec.parentRefs", [input.metadata.name])
}

deny contains msg if {
  input.kind == "HTTPRoute"
  count(input.spec.parentRefs) == 0
  msg := sprintf("HTTPRoute '%s' has empty spec.parentRefs", [input.metadata.name])
}

deny contains msg if {
  input.kind == "HTTPRoute"
  count(input.spec.parentRefs) > 0
  not input.spec.parentRefs[0].name
  msg := sprintf("HTTPRoute '%s' parentRefs[0].name is not set", [input.metadata.name])
}
