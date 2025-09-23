package main
import rego.v1

# Test that smart authentication configuration auto-populates when keycloak is enabled
# and original values are empty

# Check that authentication issuer is auto-populated with keycloak URL
deny contains msg if {
  # Convert input to string for pattern matching
  input_str := sprintf("%v", [input])

  # Look for rendered values in any resource that contains authentication config
  contains(input_str, "authentication:")
  contains(input_str, "oidc:")

  # When keycloak is enabled and issuer was null, it should be auto-populated
  not contains(input_str, "issuer: https://id-test.test-smart-config.example/realms/mijnbureau")

  msg := "Smart authentication: issuer should be auto-populated when keycloak is enabled and issuer is empty"
}

# Check that authorization_endpoint is auto-populated
deny contains msg if {
  input_str := sprintf("%v", [input])
  contains(input_str, "authentication:")
  contains(input_str, "oidc:")

  not contains(input_str, "authorization_endpoint: https://id-test.test-smart-config.example/realms/mijnbureau/protocol/openid-connect/auth")

  msg := "Smart authentication: authorization_endpoint should be auto-populated when keycloak is enabled and value is empty"
}

# Check that token_endpoint is auto-populated
deny contains msg if {
  input_str := sprintf("%v", [input])
  contains(input_str, "authentication:")
  contains(input_str, "oidc:")

  not contains(input_str, "token_endpoint: https://id-test.test-smart-config.example/realms/mijnbureau/protocol/openid-connect/token")

  msg := "Smart authentication: token_endpoint should be auto-populated when keycloak is enabled and value is empty"
}

# Check that jwks_uri is auto-populated
deny contains msg if {
  input_str := sprintf("%v", [input])
  contains(input_str, "authentication:")
  contains(input_str, "oidc:")

  not contains(input_str, "jwks_uri: https://id-test.test-smart-config.example/realms/mijnbureau/protocol/openid-connect/certs")

  msg := "Smart authentication: jwks_uri should be auto-populated when keycloak is enabled and value is empty"
}
