package main
import rego.v1

# Test that smart AI configuration auto-populates when ollama is enabled
# and original values are empty

# Check that AI model is auto-populated with ollama model
deny contains msg if {
  input_str := sprintf("%v", [input])
  # Look for rendered values that contain AI config
  contains(input_str, "ai:")
  contains(input_str, "llm:")

  # When ollama is enabled and model was null, it should be auto-populated
  not contains(input_str, "model: llama3.2")

  msg := "Smart AI: model should be auto-populated with ollama model when ollama is enabled and model is empty"
}

# Check that AI endpoint is auto-populated with kubernetes service URL
deny contains msg if {
  input_str := sprintf("%v", [input])
  contains(input_str, "ai:")
  contains(input_str, "llm:")

  not contains(input_str, "endpoint: http://ollama.test-namespace.svc.cluster.local:11434")

  msg := "Smart AI: endpoint should be auto-populated with kubernetes service URL when ollama is enabled and endpoint is empty"
}

# Check that AI apiKey is auto-populated with empty string for ollama
deny contains msg if {
  input_str := sprintf("%v", [input])
  contains(input_str, "ai:")
  contains(input_str, "llm:")

  # For ollama, apiKey should be empty string
  not contains(input_str, "apiKey: \"\"")

  msg := "Smart AI: apiKey should be auto-populated with empty string when ollama is enabled and apiKey is empty"
}
