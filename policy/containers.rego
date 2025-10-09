package main
import rego.v1

# Disallow containers running as root, configured globally by settings runAsUser 0
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  input.spec.template.spec.securityContext.runAsUser == 0
  msg := "Pod-level runAsUser is set to 0 (root user)"
}

# Disallow containers running as root, with setting runAsUser 0
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.containers[i]
  container.securityContext.runAsUser == 0
  msg := sprintf("Container '%s' has runAsUser set to 0 (root user)", [container.name])
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.initContainers[i]
  container.securityContext.runAsUser == 0
  msg := sprintf("initContainer '%s' has runAsUser set to 0 (root user)", [container.name])
}

# Disallow containers running as root - hierarchical runAsNonRoot check
# A container may run as root if BOTH pod-level AND container-level allow root
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.containers[i]

  # Check if pod-level runAsNonRoot provides protection
  pod_allows_root := input.spec.template.spec.securityContext.runAsNonRoot != true

  # Check if container-level runAsNonRoot provides protection
  container_allows_root := container.securityContext.runAsNonRoot != true

  # If both levels allow root, it's a violation
  pod_allows_root
  container_allows_root

  msg := sprintf("Container '%s' may run as root: neither pod-level nor container-level runAsNonRoot is set to true", [container.name])
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.initContainers[i]

  # Check if pod-level runAsNonRoot provides protection
  pod_allows_root := input.spec.template.spec.securityContext.runAsNonRoot != true

  # Check if container-level runAsNonRoot provides protection
  container_allows_root := container.securityContext.runAsNonRoot != true

  # If both levels allow root, it's a violation
  pod_allows_root
  container_allows_root

  msg := sprintf("initContainer '%s' may run as root: neither pod-level nor container-level runAsNonRoot is set to true", [container.name])
}

# Disallow containers with runAsNonRoot explicitly set to false
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.containers[i]
  container.securityContext.runAsNonRoot == false
  msg := sprintf("Container '%s' has runAsNonRoot explicitly set to false", [container.name])
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.initContainers[i]
  container.securityContext.runAsNonRoot == false
  msg := sprintf("initContainer '%s' has runAsNonRoot explicitly set to false", [container.name])
}

#disallow latest tag
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.containers[i]
  endswith(container.image, ":latest")
  msg := sprintf("Container '%s' uses 'latest' tag", [container.name])
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.initContainers[i]
  endswith(container.image, ":latest")
  msg := sprintf("initContainer '%s' uses 'latest' tag", [container.name])
}

# Disallow privileged containers
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.containers[i]
  container.securityContext.privileged == true
  msg := sprintf("Container '%s' is running in privileged mode", [container.name])
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.initContainers[i]
  container.securityContext.privileged == true
  msg := sprintf("initContainer '%s' is running in privileged mode", [container.name])
}

# Require resource limits and requests for all containers
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some c in input.spec.template.spec.containers
  not c.resources.limits
  msg := sprintf("Container '%s' must have resource limits", [c.name])
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some c in input.spec.template.spec.initContainers
  not c.resources.limits
  msg := sprintf("initContainer '%s' must have resource limits", [c.name])
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some c in input.spec.template.spec.containers
  not c.resources.requests
  msg := sprintf("Container '%s' must have resource requests", [c.name])
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some c in input.spec.template.spec.initContainers
  not c.resources.requests
  msg := sprintf("initContainer '%s' must have resource requests", [c.name])
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
  msg := sprintf("Container '%s' image must have a tag", [c.name])
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some c in input.spec.template.spec.initContainers
  not contains(c.image, ":")
  msg := sprintf("InitContainer '%s' image must have a tag", [c.name])
}

# Disallow hostPath volumes
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some v
  volume := input.spec.template.spec.volumes[v]
  volume.hostPath
  msg := sprintf("hostPath volume '%s' is not allowed", [volume.name])
}

# Disallow containers with allowPrivilegeEscalation: true
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.containers[i]
  container.securityContext.allowPrivilegeEscalation == true
  msg := sprintf("Container '%s' allows privilege escalation", [container.name])
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}
  some i
  container := input.spec.template.spec.initContainers[i]
  container.securityContext.allowPrivilegeEscalation == true
  msg := sprintf("initContainer '%s' allows privilege escalation", [container.name])
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
