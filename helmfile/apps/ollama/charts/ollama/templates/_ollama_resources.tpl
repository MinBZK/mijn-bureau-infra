{{/*
Ollama-specific resource presets.
Ollama requires significant resources for LLM inference.
Minimum ~2 CPU and 8 GiB RAM for small models (3B parameters).
Memory scales with model size: ~1 GiB per billion parameters (quantized Q4).
Presets below "2xlarge" are overridden to meet Ollama's minimum requirements.
{{ include "ollama.resources.preset" (dict "type" "nano") -}}
*/}}
{{- define "ollama.resources.preset" -}}
{{- $presets := dict
  "nano" (dict
      "requests" (dict "cpu" "2" "memory" "8Gi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "4" "memory" "12Gi" "ephemeral-storage" "2Gi")
   )
  "micro" (dict
      "requests" (dict "cpu" "2" "memory" "8Gi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "4" "memory" "12Gi" "ephemeral-storage" "2Gi")
   )
  "small" (dict
      "requests" (dict "cpu" "2" "memory" "8Gi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "4" "memory" "12Gi" "ephemeral-storage" "2Gi")
   )
  "medium" (dict
      "requests" (dict "cpu" "2" "memory" "8Gi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "4" "memory" "12Gi" "ephemeral-storage" "2Gi")
   )
  "large" (dict
      "requests" (dict "cpu" "2" "memory" "8Gi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "4" "memory" "12Gi" "ephemeral-storage" "2Gi")
   )
  "xlarge" (dict
      "requests" (dict "cpu" "2" "memory" "8Gi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "4" "memory" "12Gi" "ephemeral-storage" "2Gi")
   )
  "2xlarge" (dict
      "requests" (dict "cpu" "2" "memory" "8Gi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "8" "memory" "16Gi" "ephemeral-storage" "2Gi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}
