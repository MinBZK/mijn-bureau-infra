package main
import rego.v1

deny contains msg if {
  input.kind == "Deployment"
  some i
  container := input.spec.template.spec.containers[i]
  not startswith(container.image, "test-registry.example.com/")
  msg := sprintf("Container '%s' in Deployment '%s' does not use test registry 'test-registry.example.com' in image '%s' (propagation failed)", [container.name, input.metadata.name, container.image])
}
