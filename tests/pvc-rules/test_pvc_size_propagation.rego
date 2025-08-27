package main
import rego.v1

# Test that PVC values from test config properly propagate to PersistentVolumeClaim resources
deny contains msg if {
  input.kind == "PersistentVolumeClaim"
  not input.spec.resources.requests.storage == "42Gi"
  msg := sprintf("PersistentVolumeClaim '%s' does not have test storage size '42Gi' (propagation failed)", [input.metadata.name])
}
