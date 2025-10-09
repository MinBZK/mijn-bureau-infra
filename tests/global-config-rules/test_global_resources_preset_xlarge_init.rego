package main
import rego.v1

# Test that global.resourcesPreset: "xlarge" results in exact expected resource allocations
# Based on Bitnami common template, xlarge preset should have:
# requests: cpu: "1.0", memory: "3072Mi", ephemeral-storage: "50Mi"
# limits: cpu: "3.0", memory: "6144Mi", ephemeral-storage: "2Gi"

# Verify CPU requests match xlarge preset (1.0 or 1000m)
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet"}
  some i
  container := input.spec.template.spec.initContainers[i]
  container.resources.requests
  cpu_request := container.resources.requests.cpu
  not cpu_request in {"1.0", "1000m", "1"}
  msg := sprintf("Container '%s' in '%s' '%s' has CPU request '%s' but xlarge preset should set '1.0' (propagation failed)", [container.name, input.kind, input.metadata.name, cpu_request])
}

# Verify memory requests match xlarge preset (3072Mi)
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet"}
  some i
  container := input.spec.template.spec.initContainers[i]
  container.resources.requests
  memory_request := container.resources.requests.memory
  not memory_request == "3072Mi"
  msg := sprintf("initContainers '%s' in '%s' '%s' has memory request '%s' but xlarge preset should set '3072Mi' (propagation failed)", [container.name, input.kind, input.metadata.name, memory_request])
}

# Verify CPU limits match xlarge preset (3.0 or 3000m)
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet"}
  some i
  container := input.spec.template.spec.initContainers[i]
  container.resources.limits
  cpu_limit := container.resources.limits.cpu
  not cpu_limit in {"3.0", "3000m", "3"}
  msg := sprintf("initContainers '%s' in '%s' '%s' has CPU limit '%s' but xlarge preset should set '3.0' (propagation failed)", [container.name, input.kind, input.metadata.name, cpu_limit])
}

# Verify memory limits match xlarge preset (6144Mi)
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet"}
  some i
  container := input.spec.template.spec.initContainers[i]
  container.resources.limits
  memory_limit := container.resources.limits.memory
  not memory_limit == "6144Mi"
  msg := sprintf("initContainers '%s' in '%s' '%s' has memory limit '%s' but xlarge preset should set '6144Mi' (propagation failed)", [container.name, input.kind, input.metadata.name, memory_limit])
}

# Verify ephemeral-storage requests match xlarge preset (50Mi)
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet"}
  some i
  container := input.spec.template.spec.initContainers[i]
  container.resources.requests
  ephemeral_request := container.resources.requests["ephemeral-storage"]
  ephemeral_request  # Only test if ephemeral-storage is set
  not ephemeral_request == "50Mi"
  msg := sprintf("initContainers '%s' in '%s' '%s' has ephemeral-storage request '%s' but xlarge preset should set '50Mi' (propagation failed)", [container.name, input.kind, input.metadata.name, ephemeral_request])
}

# Verify ephemeral-storage limits match xlarge preset (2Gi)
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet"}
  some i
  container := input.spec.template.spec.initContainers[i]
  container.resources.limits
  ephemeral_limit := container.resources.limits["ephemeral-storage"]
  ephemeral_limit  # Only test if ephemeral-storage is set
  not ephemeral_limit == "2Gi"
  msg := sprintf("initContainers '%s' in '%s' '%s' has ephemeral-storage limit '%s' but xlarge preset should set '2Gi' (propagation failed)", [container.name, input.kind, input.metadata.name, ephemeral_limit])
}
