package main
import rego.v1

deny contains msg if {
  input.kind in {"Ingress"}
  not input.spec.ingressClassName
  msg := "cluster.ingress.className not properly configured in Ingress spec"
}

deny contains msg if {
  input.kind in {"Ingress"}
  input.spec.ingressClassName != "test-ingress-class"
  msg := "cluster.ingress.className value not propagated correctly to Ingress spec"
}
