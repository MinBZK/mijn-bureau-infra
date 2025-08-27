package main
import rego.v1

# Test that global.resourcesPreset propagates to Deployments by ensuring containers have resource specifications
# Since resourcesPreset gets converted to actual resource limits/requests by Bitnami charts,
# we verify that containers have resources defined (indicating preset was applied)

deny contains msg if {
  input.kind == "Deployment"
  some i
  container := input.spec.template.spec.containers[i]
  # Check if container has NO resources defined (neither requests nor limits)
  not container.resources.requests
  not container.resources.limits
  msg := sprintf("Container '%s' in Deployment '%s' has no resource requests or limits defined - global.resourcesPreset may not be properly propagating", [container.name, input.metadata.name])
}

# Test that StatefulSets also get resource specifications from global.resourcesPreset
deny contains msg if {
  input.kind == "StatefulSet"
  some i
  container := input.spec.template.spec.containers[i]
  # Check if container has NO resources defined (neither requests nor limits)
  not container.resources.requests
  not container.resources.limits
  msg := sprintf("Container '%s' in StatefulSet '%s' has no resource requests or limits defined - global.resourcesPreset may not be properly propagating", [container.name, input.metadata.name])
}

# Additional check: if resources are defined, ensure they have meaningful values
deny contains msg if {
  input.kind in {"Deployment", "StatefulSet"}
  some i
  container := input.spec.template.spec.containers[i]
  container.resources.requests
  # Check for empty or zero CPU requests (indicating improper preset application)
  container.resources.requests.cpu == ""
  msg := sprintf("Container '%s' in '%s' '%s' has empty CPU request - global.resourcesPreset may not be applied correctly", [container.name, input.kind, input.metadata.name])
}

deny contains msg if {
  input.kind in {"Deployment", "StatefulSet"}
  some i
  container := input.spec.template.spec.containers[i]
  container.resources.requests
  # Check for empty or zero memory requests (indicating improper preset application)
  container.resources.requests.memory == ""
  msg := sprintf("Container '%s' in '%s' '%s' has empty memory request - global.resourcesPreset may not be applied correctly", [container.name, input.kind, input.metadata.name])
}
