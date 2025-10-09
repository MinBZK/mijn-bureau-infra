package main
import rego.v1

# Test that security context values from test config properly propagate to Deployment containers
deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.initContainers[i]
  not container.securityContext.runAsUser == 9999
  msg := sprintf("InitContainer '%s' in Deployment '%s' does not have test runAsUser value 9999 (propagation failed)", [container.name, input.metadata.name])
}

deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.initContainers[i]
  not container.securityContext.runAsGroup == 8888
  msg := sprintf("InitContainer '%s' in Deployment '%s' does not have test runAsGroup value 8888 (propagation failed)", [container.name, input.metadata.name])
}

deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.initContainers[i]
  not container.securityContext.runAsNonRoot == true
  msg := sprintf("InitContainer '%s' in Deployment '%s' does not have runAsNonRoot set to true (propagation failed)", [container.name, input.metadata.name])
}

deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.initContainers[i]
  not container.securityContext.allowPrivilegeEscalation == false
  msg := sprintf("InitContainer '%s' in Deployment '%s' does not have allowPrivilegeEscalation set to false (propagation failed)", [container.name, input.metadata.name])
}

deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.initContainers[i]
  not container.securityContext.readOnlyRootFilesystem == true
  msg := sprintf("InitContainer '%s' in Deployment '%s' does not have readOnlyRootFilesystem set to true (propagation failed)", [container.name, input.metadata.name])
}

deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.initContainers[i]
  not "ALL" in container.securityContext.capabilities.drop
  msg := sprintf("InitContainer '%s' in Deployment '%s' does not drop ALL capabilities (propagation failed)", [container.name, input.metadata.name])
}
