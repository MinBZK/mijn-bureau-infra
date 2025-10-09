package main
import rego.v1

# Test that component-level resources properly propagate to Deployments
# Grist main app should have CPU request of 500m
deny contains msg if {
  input.kind == "Deployment"
  input.metadata.name == "grist"
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "grist"
  not container.resources.requests.cpu == "500m"
  msg := sprintf("initContainers '%s' in Deployment '%s' does not have expected CPU request '500m' (got '%s') - resource.grist.grist propagation failed", [container.name, input.metadata.name, container.resources.requests.cpu])
}

# Grist main app should have memory request of 1Gi
deny contains msg if {
  input.kind == "Deployment"
  input.metadata.name == "grist"
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "grist"
  not container.resources.requests.memory == "1Gi"
  msg := sprintf("initContainers '%s' in Deployment '%s' does not have expected memory request '1Gi' (got '%s') - resource.grist.grist propagation failed", [container.name, input.metadata.name, container.resources.requests.memory])
}

# Test PostgreSQL resources propagate to StatefulSet
deny contains msg if {
  input.kind == "StatefulSet"
  contains(input.metadata.name, "postgresql")
  contains(input.metadata.name, "grist")
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "postgresql"
  not container.resources.requests.cpu == "250m"
  msg := sprintf("initContainers '%s' in StatefulSet '%s' does not have expected CPU request '250m' (got '%s') - resource.grist.postgresql propagation failed", [container.name, input.metadata.name, container.resources.requests.cpu])
}

deny contains msg if {
  input.kind == "StatefulSet"
  contains(input.metadata.name, "postgresql")
  contains(input.metadata.name, "grist")
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "postgresql"
  not container.resources.requests.memory == "512Mi"
  msg := sprintf("initContainers '%s' in StatefulSet '%s' does not have expected memory request '512Mi' (got '%s') - resource.grist.postgresql propagation failed", [container.name, input.metadata.name, container.resources.requests.memory])
}

# Test Redis resources propagate to StatefulSet
deny contains msg if {
  input.kind == "StatefulSet"
  contains(input.metadata.name, "redis")
  contains(input.metadata.name, "grist")
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "redis"
  not container.resources.requests.cpu == "100m"
  msg := sprintf("initContainers '%s' in StatefulSet '%s' does not have expected CPU request '100m' (got '%s') - resource.grist.redis propagation failed", [container.name, input.metadata.name, container.resources.requests.cpu])
}

deny contains msg if {
  input.kind == "StatefulSet"
  contains(input.metadata.name, "redis")
  contains(input.metadata.name, "grist")
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "redis"
  not container.resources.requests.memory == "256Mi"
  msg := sprintf("initContainers '%s' in StatefulSet '%s' does not have expected memory request '256Mi' (got '%s') - resource.grist.redis propagation failed", [container.name, input.metadata.name, container.resources.requests.memory])
}

# Test MinIO resources propagate to Deployment/StatefulSet
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet"}
  contains(input.metadata.name, "minio")
  contains(input.metadata.name, "grist")
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "minio"
  not container.resources.requests.cpu == "200m"
  msg := sprintf("initContainers '%s' in '%s' '%s' does not have expected CPU request '200m' (got '%s') - resource.grist.minio propagation failed", [container.name, input.kind, input.metadata.name, container.resources.requests.cpu])
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet"}
  contains(input.metadata.name, "minio")
  contains(input.metadata.name, "grist")
  some i
  container := input.spec.template.spec.initContainers[i]
  container.name == "minio"
  not container.resources.requests.memory == "512Mi"
  msg := sprintf("initContainers '%s' in '%s' '%s' does not have expected memory request '512Mi' (got '%s') - resource.grist.minio propagation failed", [container.name, input.kind, input.metadata.name, container.resources.requests.memory])
}
