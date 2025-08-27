package main
import rego.v1

deny contains msg if {
  input.kind == "PersistentVolumeClaim"
  not input.spec.storageClassName == "test-propagation-storage"
  msg := sprintf("PersistentVolumeClaim '%s' does not have test storageClass 'test-propagation-storage' (propagation failed)", [input.metadata.name])
}
