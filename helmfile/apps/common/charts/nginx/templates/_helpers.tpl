{{/*
Render the main container resources from either explicit values or the
Bitnami-compatible resourcesPreset value used by the existing environment files.
*/}}
{{- define "nginx.resources" -}}
{{- if .Values.resources -}}
{{- toYaml .Values.resources -}}
{{- else if ne (default "none" .Values.resourcesPreset) "none" -}}
{{- include "common.resources.preset" (dict "type" .Values.resourcesPreset) -}}
{{- else -}}
{}
{{- end -}}
{{- end -}}

{{- define "nginx.metrics.resources" -}}
{{- if .Values.metrics.resources -}}
{{- toYaml .Values.metrics.resources -}}
{{- else if ne (default "none" .Values.metrics.resourcesPreset) "none" -}}
{{- include "common.resources.preset" (dict "type" .Values.metrics.resourcesPreset) -}}
{{- else -}}
{}
{{- end -}}
{{- end -}}

{{/*
Strip the Bitnami-only "enabled" key from the security context values.
*/}}
{{- define "nginx.podSecurityContext" -}}
{{- omit .Values.podSecurityContext "enabled" | toYaml -}}
{{- end -}}

{{- define "nginx.containerSecurityContext" -}}
{{- omit .Values.containerSecurityContext "enabled" | toYaml -}}
{{- end -}}
