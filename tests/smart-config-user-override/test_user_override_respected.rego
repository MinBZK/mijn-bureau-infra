package main

import rego.v1

# When the user provides custom authentication.oidc.* and ai.llm.* values,
# the logic layer must leave them untouched: no auto-generated keycloak or
# ollama values may appear in the rendered manifests. This also guards the
# all-values-overridden case, where the logic layer must emit nothing at
# all (an empty map would null out the whole subtree on merge).

computed_kc_base := "https://id-test.test-override.example/realms/mijnbureau"

meet_expected := {
	"OIDC_OP_AUTHORIZATION_ENDPOINT": "https://custom-auth.example.com/auth",
	"OIDC_OP_TOKEN_ENDPOINT": "https://custom-auth.example.com/token",
	"OIDC_OP_USER_ENDPOINT": "https://custom-auth.example.com/userinfo",
	"OIDC_OP_JWKS_ENDPOINT": "https://custom-auth.example.com/certs",
	"OIDC_OP_LOGOUT_ENDPOINT": "https://custom-auth.example.com/logout",
}

deny contains msg if {
	input.kind == "ConfigMap"
	input.data.OIDC_RP_CLIENT_ID == "meet"
	some key, expected in meet_expected
	object.get(input.data, key, "") != expected
	msg := sprintf(
		"user override: meet ConfigMap %s should keep the custom value %q, got %q",
		[key, expected, object.get(input.data, key, "")],
	)
}

deny contains msg if {
	input.kind == "Deployment"
	some container in input.spec.template.spec.containers
	some scope in container.env
	scope.name == "OIDC_CLIENT_ID"
	scope.value == "bureaublad"
	some env in container.env
	env.name == "OIDC_ISSUER"
	object.get(env, "value", "") != "https://custom-auth.example.com/realms/custom"
	msg := sprintf(
		"user override: bureaublad OIDC_ISSUER should keep the custom value, got %q",
		[object.get(env, "value", "")],
	)
}

# No resource may carry an auto-generated keycloak URL when the user
# provided custom authentication values.
deny contains msg if {
	walk(input, [path, value])
	is_string(value)
	contains(value, computed_kc_base)
	msg := sprintf(
		"user override: auto-generated keycloak URL %q must not appear when custom authentication values are set (found at %v)",
		[computed_kc_base, path],
	)
}

ai_expected := {
	"AI_BASE_URL": "https://custom-ai.example.com:443/v1",
	"AI_MODEL": "custom-model",
	"AI_API_KEY": "custom-api-key",
}

deny contains msg if {
	input.kind == "ConfigMap"
	"AI_BASE_URL" in object.keys(input.data)
	some key, expected in ai_expected
	object.get(input.data, key, "") != expected
	msg := sprintf(
		"user override: ConfigMap %s should keep the custom value %q, got %q",
		[key, expected, object.get(input.data, key, "")],
	)
}
