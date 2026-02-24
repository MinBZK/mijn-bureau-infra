package main
import rego.v1

# Deny HTTPRoute rules that carry no HSTS header, but only when:
#   - the rule is not a pure redirect (redirect rules don't serve content)
#   - the route is not annotated as running under a self-signed certificate
#     (browsers cannot satisfy HSTS with self-signed certs)
deny contains msg if {
  input.kind == "HTTPRoute"
  not is_self_signed(input)
  some rule in input.spec.rules
  not is_redirect_rule(rule)
  not has_hsts_filter(rule)
  msg := sprintf("HTTPRoute '%s' rule is missing HSTS ResponseHeaderModifier filter", [input.metadata.name])
}

has_hsts_filter(rule) if {
  some filter in rule.filters
  filter.type == "ResponseHeaderModifier"
  some header in filter.responseHeaderModifier.set
  header.name == "Strict-Transport-Security"
}

# A rule whose only meaningful filter is a RequestRedirect does not serve
# response bodies, so an HSTS header is both unnecessary and impossible.
is_redirect_rule(rule) if {
  some filter in rule.filters
  filter.type == "RequestRedirect"
}

# Routes deployed in a self-signed TLS environment are annotated so that
# policy checks can skip the HSTS requirement.
is_self_signed(resource) if {
  resource.metadata.annotations["mijnbureau.nl/tls-self-signed"] == "true"
}
