package main
import rego.v1

# for all kubernetes manifests require namespace label in metadata
deny contains msg if {
  not input.metadata.namespace
  msg := sprintf("Resource %q of kind %q does not have a namespace defined.", [input.metadata.name, input.kind])
}
