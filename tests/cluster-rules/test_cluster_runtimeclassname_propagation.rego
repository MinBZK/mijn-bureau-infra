package main
import rego.v1

# Helper function to check if a deployment should be excluded from runtimeClassName testing
is_excluded_deployment(deployment_name) if {
  # MinIO console deployments do not support runtimeClassName in the Bitnami chart
  # See: https://github.com/bitnami/charts/blob/main/bitnami/minio/templates/console/deployment.yaml
  # The console deployment template lacks runtimeClassName support entirely
  endswith(deployment_name, "-minio-console")
}

# Test that runtimeClassName from cluster config properly propagates to Deployment specs
deny contains msg if {
  input.kind == "Deployment"
  not is_excluded_deployment(input.metadata.name)
  not input.spec.template.spec.runtimeClassName
  msg := sprintf("Deployment '%s' does not have runtimeClassName set (propagation failed)", [input.metadata.name])
}

deny contains msg if {
  input.kind == "Deployment"
  not is_excluded_deployment(input.metadata.name)
  input.spec.template.spec.runtimeClassName != "test-runtime-class"
  msg := sprintf("Deployment '%s' does not have test runtimeClassName value 'test-runtime-class' (propagation failed)", [input.metadata.name])
}
