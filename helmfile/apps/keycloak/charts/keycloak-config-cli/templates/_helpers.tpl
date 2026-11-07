{{- define "keycloak-config-cli.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "keycloak-config-cli.selectorLabels" -}}
app.kubernetes.io/name: keycloak-config-cli
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "keycloak-config-cli.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "keycloak-config-cli.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: keycloak-config-cli
app.kubernetes.io/part-of: keycloak
{{- end -}}
