package main
import rego.v1

# Test that security context values from test config properly propagate to Deployment containers
deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.containers[i]
  not container.securityContext.runAsUser == 9999
  msg := sprintf("Container '%s' in Deployment '%s' does not have test runAsUser value 9999 (propagation failed)", [container.name, input.metadata.name])
}

deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.containers[i]
  not container.securityContext.runAsGroup == 8888
  msg := sprintf("Container '%s' in Deployment '%s' does not have test runAsGroup value 8888 (propagation failed)", [container.name, input.metadata.name])
}

deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.containers[i]
  not container.securityContext.runAsNonRoot == true
  msg := sprintf("Container '%s' in Deployment '%s' does not have runAsNonRoot set to true (propagation failed)", [container.name, input.metadata.name])
}

deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.containers[i]
  not container.securityContext.allowPrivilegeEscalation == false
  msg := sprintf("Container '%s' in Deployment '%s' does not have allowPrivilegeEscalation set to false (propagation failed)", [container.name, input.metadata.name])
}

deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.containers[i]
  not container.securityContext.readOnlyRootFilesystem == true
  msg := sprintf("Container '%s' in Deployment '%s' does not have readOnlyRootFilesystem set to true (propagation failed)", [container.name, input.metadata.name])
}

deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.containers[i]
  not "ALL" in container.securityContext.capabilities.drop
  msg := sprintf("Container '%s' in Deployment '%s' does not drop ALL capabilities (propagation failed)", [container.name, input.metadata.name])
}

# Test that pod security context values from test config properly propagate to Deployments
deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  not input.spec.template.spec.securityContext.fsGroup == 7777
  msg := sprintf("Deployment '%s' does not have test fsGroup value 7777 (propagation failed)", [input.metadata.name])
}

deny contains msg if {
  input.kind == {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  not input.spec.template.spec.securityContext.fsGroupChangePolicy == "TestingPropagation"
  msg := sprintf("Deployment '%s' does not have test fsGroupChangePolicy value 'TestingPropagation' (propagation failed)", [input.metadata.name])
}
