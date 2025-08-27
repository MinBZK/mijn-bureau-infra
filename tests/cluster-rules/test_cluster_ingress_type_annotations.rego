package main
import rego.v1

deny contains msg if {
  input.kind in {"Ingress"}
  not input.metadata.annotations["nginx.ingress.kubernetes.io/force-ssl-redirect"]
  msg := "cluster.ingress.type nginx annotations not properly configured - missing force-ssl-redirect"
}

deny contains msg if {
  input.kind in {"Ingress"}
  input.metadata.annotations["nginx.ingress.kubernetes.io/force-ssl-redirect"] != "true"
  msg := "cluster.ingress.type nginx annotations not properly configured - force-ssl-redirect should be 'true'"
}

deny contains msg if {
  input.kind in {"Ingress"}
  not input.metadata.annotations["nginx.ingress.kubernetes.io/configuration-snippet"]
  msg := "cluster.ingress.type nginx annotations not properly configured - missing configuration-snippet for HSTS"
}

deny contains msg if {
  input.kind in {"Ingress"}
  not contains(input.metadata.annotations["nginx.ingress.kubernetes.io/configuration-snippet"], "Strict-Transport-Security")
  msg := "cluster.ingress.type nginx annotations not properly configured - configuration-snippet missing HSTS header"
}
