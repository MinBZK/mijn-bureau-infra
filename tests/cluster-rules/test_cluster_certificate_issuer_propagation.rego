package main
import rego.v1

deny contains msg if {
  input.kind in {"Ingress"}
  input.spec.tls
  not input.metadata.annotations["cert-manager.io/cluster-issuer"]
  msg := "cluster.certificate.issuer not properly configured in Ingress annotations"
}

deny contains msg if {
  input.kind in {"Ingress"}
  input.spec.tls
  input.metadata.annotations["cert-manager.io/cluster-issuer"] != "test-cert-issuer"
  msg := "cluster.certificate.issuer value not propagated correctly to Ingress annotations"
}
