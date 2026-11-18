{{- define "openai-shim.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "openai-shim.fullname" -}}
{{- if contains .Chart.Name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "openai-shim.labels" -}}
app.kubernetes.io/name: {{ include "openai-shim.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: openai-shim
app.kubernetes.io/part-of: mijn-bureau
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "openai-shim.serviceAccountName" -}}
{{- include "openai-shim.fullname" . -}}
{{- end -}}
