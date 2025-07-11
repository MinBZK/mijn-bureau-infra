package main
import rego.v1

# Disallow containers running as root, configured globally by settings runAsUser 0
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  input.spec.template.spec.securityContext.runAsUser == 0

  msg := "Containers must not run as root, check runAsUser"
}

# Disallow containers running as root, with setting runAsUser 0
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  input.spec.template.spec.containers[_].securityContext.runAsUser == 0

  msg := "Containers must not run as root, check runAsUser"
}

# Disallow containers running as root, configured globally by setting runAsRoot true
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  not input.spec.template.spec.securityContext.runAsNonRoot
  msg := "Containers must not run as root, check runAsNonRoot"
}

# Disallow containers running as root, with setting runAsRoot true
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  input.spec.template.spec.containers[i].securityContext.runAsNonRoot
  msg := "Containers must not run as root, check runAsNonRoot"
}

#disallow latest tag
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  input.spec.template.spec.containers[_].image == "latest"

  msg := "Containers must not use the latest tag"
}

# Disallow privileged containers
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  input.spec.template.spec.containers[i].securityContext.privileged == true

  msg := "Privileged containers are not allowed"
}

# Require resource limits and requests for all containers
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some c in input.spec.template.spec.containers
  not c.resources.limits
  msg := "All containers must have resource limits"
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some c in input.spec.template.spec.containers
  not c.resources.requests
  msg := "All containers must have resource requests"
}

# Disallow use of default service account
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  not input.spec.template.spec.serviceAccountName
  msg := "A custom service account must be specified (do not use default)"
}

# Require image tag (not just latest or empty)
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some c in input.spec.template.spec.containers
  not contains(c.image, ":")
  msg := "All container images must have a tag"
}

# Disallow hostPath volumes
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some v
  input.spec.template.spec.volumes[v].hostPath
  msg := "hostPath volumes are not allowed"
}

# Disallow containers with allowPrivilegeEscalation: true
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  input.spec.template.spec.containers[i].securityContext.allowPrivilegeEscalation == true
  msg := "Containers must not allow privilege escalation"
}

# Disallow containers with hostNetwork: true
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  input.spec.template.spec.hostNetwork == true
  msg := "hostNetwork must not be enabled"
}

# Disallow containers with hostPID: true or hostIPC: true
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  input.spec.template.spec.hostPID == true
  msg := "hostPID must not be enabled"
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  input.spec.template.spec.hostIPC == true
  msg := "hostIPC must not be enabled"
}
