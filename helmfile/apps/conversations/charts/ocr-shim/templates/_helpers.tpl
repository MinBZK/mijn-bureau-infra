{{- define "ocr-shim.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ocr-shim.fullname" -}}
{{- if contains .Chart.Name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ocr-shim.labels" -}}
app.kubernetes.io/name: {{ include "ocr-shim.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: ocr-shim
app.kubernetes.io/part-of: mijn-bureau
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "ocr-shim.serviceAccountName" -}}
{{- include "ocr-shim.fullname" . -}}
{{- end -}}
