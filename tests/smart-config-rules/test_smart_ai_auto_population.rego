package main

import rego.v1

# When ollama is enabled and ai.llm.* values are left empty, the AI
# configuration must resolve to the in-cluster ollama service and the
# configured ollama model. Asserted on the rendered conversations
# ConfigMap, the consumer of ai.llm.*.

ai_expected := {
	"AI_BASE_URL": "http://ollama:11434/v1",
	"AI_MODEL": "llama3.2",
	"AI_API_KEY": "",
}

deny contains msg if {
	input.kind == "ConfigMap"
	"AI_BASE_URL" in object.keys(input.data)
	some key, expected in ai_expected
	object.get(input.data, key, "") != expected
	msg := sprintf(
		"smart AI: ConfigMap %s should resolve to %q when ollama is enabled and ai.llm values are empty, got %q",
		[key, expected, object.get(input.data, key, "")],
	)
}
