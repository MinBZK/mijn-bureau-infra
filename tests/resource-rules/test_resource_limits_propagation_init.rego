package main
import rego.v1

# Test that resource limits (not just requests) properly propagate

# Grist main app should have CPU limit of 1000m
deny contains msg if {
  input.kind == "Deployment"
  input.metadata.name == "grist"
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "grist"
  not container.resources.limits.cpu == "1000m"
  msg := sprintf("initContainers '%s' in Deployment '%s' does not have expected CPU limit '1000m' (got '%s') - resource.grist.grist limits propagation failed", [container.name, input.metadata.name, container.resources.limits.cpu])
}

# Grist main app should have memory limit of 2Gi
deny contains msg if {
  input.kind == "Deployment"
  input.metadata.name == "grist"
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "grist"
  not container.resources.limits.memory == "2Gi"
  msg := sprintf("initContainers '%s' in Deployment '%s' does not have expected memory limit '2Gi' (got '%s') - resource.grist.grist limits propagation failed", [container.name, input.metadata.name, container.resources.limits.memory])
}

# PostgreSQL should have CPU limit of 500m
deny contains msg if {
  input.kind == "StatefulSet"
  contains(input.metadata.name, "postgresql")
  contains(input.metadata.name, "grist")
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "postgresql"
  not container.resources.limits.cpu == "500m"
  msg := sprintf("Container '%s' in StatefulSet '%s' does not have expected CPU limit '500m' (got '%s') - resource.grist.postgresql limits propagation failed", [container.name, input.metadata.name, container.resources.limits.cpu])
}

# PostgreSQL should have memory limit of 1Gi
deny contains msg if {
  input.kind == "StatefulSet"
  contains(input.metadata.name, "postgresql")
  contains(input.metadata.name, "grist")
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "postgresql"
  not container.resources.limits.memory == "1Gi"
  msg := sprintf("initContainers '%s' in StatefulSet '%s' does not have expected memory limit '1Gi' (got '%s') - resource.grist.postgresql limits propagation failed", [container.name, input.metadata.name, container.resources.limits.memory])
}

# Redis should have CPU limit of 200m
deny contains msg if {
  input.kind == "StatefulSet"
  contains(input.metadata.name, "redis")
  contains(input.metadata.name, "grist")
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "redis"
  not container.resources.limits.cpu == "200m"
  msg := sprintf("initContainers '%s' in StatefulSet '%s' does not have expected CPU limit '200m' (got '%s') - resource.grist.redis limits propagation failed", [container.name, input.metadata.name, container.resources.limits.cpu])
}

# Redis should have memory limit of 512Mi
deny contains msg if {
  input.kind == "StatefulSet"
  contains(input.metadata.name, "redis")
  contains(input.metadata.name, "grist")
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "redis"
  not container.resources.limits.memory == "512Mi"
  msg := sprintf("initContainers '%s' in StatefulSet '%s' does not have expected memory limit '512Mi' (got '%s') - resource.grist.redis limits propagation failed", [container.name, input.metadata.name, container.resources.limits.memory])
}

# MinIO should have CPU limit of 400m
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet"}
  contains(input.metadata.name, "minio")
  contains(input.metadata.name, "grist")
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "minio"
  not container.resources.limits.cpu == "400m"
  msg := sprintf("initContainers '%s' in '%s' '%s' does not have expected CPU limit '400m' (got '%s') - resource.grist.minio limits propagation failed", [container.name, input.kind, input.metadata.name, container.resources.limits.cpu])
}

# MinIO should have memory limit of 1Gi
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet"}
  contains(input.metadata.name, "minio")
  contains(input.metadata.name, "grist")
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "minio"
  not container.resources.limits.memory == "1Gi"
  msg := sprintf("initContainers '%s' in '%s' '%s' does not have expected memory limit '1Gi' (got '%s') - resource.grist.minio limits propagation failed", [container.name, input.kind, input.metadata.name, container.resources.limits.memory])
}
