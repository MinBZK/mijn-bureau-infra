package main

import rego.v1

# When keycloak is enabled and authentication.oidc.* values are left empty,
# the logic layer (helmfile/bases/logic/authentication.yaml.gotmpl) must
# auto-populate the OIDC endpoints from the keycloak hostname and domain.
# These rules assert on rendered manifests of two independent consumers
# (meet's ConfigMap and bureaublad's Deployment) so an empty or missing
# value fails loudly instead of shipping a broken SSO configuration.

kc_base := "https://id-test.test-smart-config.example/realms/mijnbureau"

meet_expected := {
	"OIDC_OP_AUTHORIZATION_ENDPOINT": sprintf("%s/protocol/openid-connect/auth", [kc_base]),
	"OIDC_OP_TOKEN_ENDPOINT": sprintf("%s/protocol/openid-connect/token", [kc_base]),
	"OIDC_OP_USER_ENDPOINT": sprintf("%s/protocol/openid-connect/userinfo", [kc_base]),
	"OIDC_OP_JWKS_ENDPOINT": sprintf("%s/protocol/openid-connect/certs", [kc_base]),
	"OIDC_OP_LOGOUT_ENDPOINT": sprintf("%s/protocol/openid-connect/logout", [kc_base]),
}

deny contains msg if {
	input.kind == "ConfigMap"
	input.data.OIDC_RP_CLIENT_ID == "meet"
	some key, expected in meet_expected
	object.get(input.data, key, "") != expected
	msg := sprintf(
		"smart authentication: meet ConfigMap %s should be auto-populated to %q, got %q",
		[key, expected, object.get(input.data, key, "")],
	)
}

bureaublad_expected := {
	"OIDC_ISSUER": kc_base,
	"OIDC_AUTHORIZATION_ENDPOINT": sprintf("%s/protocol/openid-connect/auth", [kc_base]),
	"OIDC_TOKEN_ENDPOINT": sprintf("%s/protocol/openid-connect/token", [kc_base]),
	"OIDC_JWKS_ENDPOINT": sprintf("%s/protocol/openid-connect/certs", [kc_base]),
}

deny contains msg if {
	input.kind == "Deployment"
	some container in input.spec.template.spec.containers
	some scope in container.env
	scope.name == "OIDC_CLIENT_ID"
	scope.value == "bureaublad"
	some key, expected in bureaublad_expected
	some env in container.env
	env.name == key
	object.get(env, "value", "") != expected
	msg := sprintf(
		"smart authentication: bureaublad Deployment env %s should be auto-populated to %q, got %q",
		[key, expected, object.get(env, "value", "")],
	)
}
