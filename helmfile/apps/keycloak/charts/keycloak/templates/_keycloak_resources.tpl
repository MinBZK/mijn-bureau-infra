{{/*
Keycloak-specific resource presets.
Keycloak (JVM-based) requires a minimum of 1 vCPU and 1250 MiB RAM.
The JVM allocates 70% of memory limit for heap plus ~300 MiB non-heap.
See: https://www.keycloak.org/high-availability/multi-cluster/concepts-memory-and-cpu-sizing
Presets below "large" are overridden to meet Keycloak's minimum requirements.
{{ include "keycloak.resources.preset" (dict "type" "nano") -}}
*/}}
{{- define "keycloak.resources.preset" -}}
{{- $presets := dict
  "nano" (dict
      "requests" (dict "cpu" "1" "memory" "1280Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2" "memory" "2Gi" "ephemeral-storage" "2Gi")
   )
  "micro" (dict
      "requests" (dict "cpu" "1" "memory" "1280Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2" "memory" "2Gi" "ephemeral-storage" "2Gi")
   )
  "small" (dict
      "requests" (dict "cpu" "1" "memory" "1280Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2" "memory" "2Gi" "ephemeral-storage" "2Gi")
   )
  "medium" (dict
      "requests" (dict "cpu" "1" "memory" "1280Mi" "ephemeral-storage" "50Mi")
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
