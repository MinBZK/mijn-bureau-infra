package main
import rego.v1

deny contains msg if {
  input.kind == "PersistentVolumeClaim"
  not "ReadWriteOnce" in input.spec.accessModes
  msg := sprintf("PersistentVolumeClaim '%s' does not include test accessMode 'ReadWriteOnce' (propagation failed)", [input.metadata.name])
}

deny contains msg if {
  input.kind == "PersistentVolumeClaim"
  not "ReadOnlyMany" in input.spec.accessModes
  msg := sprintf("PersistentVolumeClaim '%s' does not include test accessMode 'ReadOnlyMany' (propagation failed)", [input.metadata.name])
}
