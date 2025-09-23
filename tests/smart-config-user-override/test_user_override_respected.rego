package main
import rego.v1

# Test that smart configuration respects user-provided values
# and does NOT override them with auto-generated values

# Check that custom authentication issuer is preserved
deny contains msg if {
  input_str := sprintf("%v", [input])
  contains(input_str, "authentication:")
  contains(input_str, "oidc:")

  # Should keep the custom issuer, not auto-populate with keycloak URL
  not contains(input_str, "issuer: https://custom-auth.example.com/realms/custom")

  msg := "User override: custom authentication issuer should be preserved, not auto-populated"
}

# Check that custom authentication endpoints are preserved
deny contains msg if {
  input_str := sprintf("%v", [input])
  contains(input_str, "authentication:")
  contains(input_str, "oidc:")

  not contains(input_str, "authorization_endpoint: https://custom-auth.example.com/auth")

  msg := "User override: custom authorization_endpoint should be preserved, not auto-populated"
}

# Check that keycloak auto-populated values are NOT present when user provides custom values
deny contains msg if {
  input_str := sprintf("%v", [input])
  contains(input_str, "authentication:")

  # Should NOT contain auto-generated keycloak URLs when user provided custom values
  contains(input_str, "https://id-test.test-override.example/realms/mijnbureau")

  msg := "User override: should not auto-populate keycloak URLs when user provided custom authentication values"
}

# Check that custom AI model is preserved
deny contains msg if {
  input_str := sprintf("%v", [input])
  contains(input_str, "ai:")
  contains(input_str, "llm:")

  # Should keep the custom model, not auto-populate with ollama model
  not contains(input_str, "model: custom-model")

  msg := "User override: custom AI model should be preserved, not auto-populated"
}

# Check that custom AI endpoint is preserved
deny contains msg if {
  input_str := sprintf("%v", [input])
  contains(input_str, "ai:")
  contains(input_str, "llm:")

  not contains(input_str, "endpoint: https://custom-ai.example.com/api")

  msg := "User override: custom AI endpoint should be preserved, not auto-populated"
}

# Check that ollama auto-populated values are NOT present when user provides custom values
deny contains msg if {
  input_str := sprintf("%v", [input])
  contains(input_str, "ai:")

  # Should NOT contain auto-generated ollama service URLs when user provided custom values
  contains(input_str, "http://ollama.test-namespace.svc.cluster.local:11434")

  msg := "User override: should not auto-populate ollama service URL when user provided custom AI values"
}
