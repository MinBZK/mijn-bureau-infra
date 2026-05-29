{{/*
ClamAV-specific resource presets.
ClamAV requires a minimum of 1 CPU and 3 GiB RAM to load virus signature databases.
See: https://docs.clamav.net/#recommended-system-requirements
Presets below "xlarge" are overridden to meet ClamAV's minimum requirements.
{{ include "clamav.resources.preset" (dict "type" "nano") -}}
*/}}
{{- define "clamav.resources.preset" -}}
{{- $presets := dict
  "nano" (dict
      "requests" (dict "cpu" "1" "memory" "3Gi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2" "memory" "4Gi" "ephemeral-storage" "2Gi")
   )
  "micro" (dict
      "requests" (dict "cpu" "1" "memory" "3Gi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2" "memory" "4Gi" "ephemeral-storage" "2Gi")
   )
  "small" (dict
      "requests" (dict "cpu" "1" "memory" "3Gi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2" "memory" "4Gi" "ephemeral-storage" "2Gi")
   )
  "medium" (dict
      "requests" (dict "cpu" "1" "memory" "3Gi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2" "memory" "4Gi" "ephemeral-storage" "2Gi")
   )
  "large" (dict
      "requests" (dict "cpu" "1" "memory" "3Gi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2" "memory" "4Gi" "ephemeral-storage" "2Gi")
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
