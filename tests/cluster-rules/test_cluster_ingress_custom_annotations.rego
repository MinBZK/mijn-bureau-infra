package main
import rego.v1

deny contains msg if {
  input.kind in {"Ingress"}
  not input.metadata.annotations["custom.annotation/test"]
  msg := "cluster.ingress.annotations not properly configured - missing custom.annotation/test"
}

deny contains msg if {
  input.kind in {"Ingress"}
  input.metadata.annotations["custom.annotation/test"] != "test-value"
  msg := "cluster.ingress.annotations not properly configured - custom.annotation/test should be 'test-value'"
}

deny contains msg if {
  input.kind in {"Ingress"}
  not input.metadata.annotations["custom.annotation/environment"]
  msg := "cluster.ingress.annotations not properly configured - missing custom.annotation/environment"
}

deny contains msg if {
  input.kind in {"Ingress"}
  input.metadata.annotations["custom.annotation/environment"] != "testing"
  msg := "cluster.ingress.annotations not properly configured - custom.annotation/environment should be 'testing'"
}
