{{/*
Collabora-specific resource presets.
Collabora Online requires a minimum of 1 CPU and 512 MiB RAM for the document rendering engine.
Memory scales with concurrent users (~50 MiB per user on top of base).
Presets below "medium" are overridden to meet Collabora's minimum requirements.
{{ include "collabora.resources.preset" (dict "type" "nano") -}}
*/}}
{{- define "collabora.resources.preset" -}}
{{- $presets := dict
  "nano" (dict
      "requests" (dict "cpu" "1" "memory" "512Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2" "memory" "1Gi" "ephemeral-storage" "2Gi")
   )
  "micro" (dict
      "requests" (dict "cpu" "1" "memory" "512Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2" "memory" "1Gi" "ephemeral-storage" "2Gi")
   )
  "small" (dict
      "requests" (dict "cpu" "1" "memory" "512Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2" "memory" "1Gi" "ephemeral-storage" "2Gi")
   )
  "medium" (dict
      "requests" (dict "cpu" "1" "memory" "1Gi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2" "memory" "2Gi" "ephemeral-storage" "2Gi")
   )
  "large" (dict
      "requests" (dict "cpu" "1.0" "memory" "2048Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "1.5" "memory" "3072Mi" "ephemeral-storage" "2Gi")
   )
  "xlarge" (dict
      "requests" (dict "cpu" "1.0" "memory" "3072Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "3.0" "memory" "6144Mi" "ephemeral-storage" "2Gi")
   )
  "2xlarge" (dict
      "requests" (dict "cpu" "1.0" "memory" "3072Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "6.0" "memory" "12288Mi" "ephemeral-storage" "2Gi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}
