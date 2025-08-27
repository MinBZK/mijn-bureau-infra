package main
import rego.v1

deny contains msg if {
  input.kind == "Deployment"
  not input.spec.template.spec.imagePullSecrets
  msg := sprintf("Deployment '%s' does not have imagePullSecrets configured (propagation failed)", [input.metadata.name])
}

deny contains msg if {
  input.kind == "Deployment"
  input.spec.template.spec.imagePullSecrets
  # Check if the test pull secret is present
  test_secret_found := [secret | secret := input.spec.template.spec.imagePullSecrets[_]; secret.name == "test-pull-secret"]
  count(test_secret_found) == 0
  msg := sprintf("Deployment '%s' does not contain test imagePullSecret 'test-pull-secret' (propagation failed)", [input.metadata.name])
}
