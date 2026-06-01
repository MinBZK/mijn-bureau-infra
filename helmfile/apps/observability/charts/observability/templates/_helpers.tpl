{{/*

SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Build the GrafanaDashboard resource name from the release fullname and the dashboard file basename.
Truncated to 63 chars to satisfy Kubernetes resource name limits.
*/}}
{{- define "observability.dashboardName" -}}
{{- $fullname := include "common.names.fullname" .context -}}
{{- printf "%s-%s" $fullname .slug | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "observability.validateValues" -}}
{{- $messages := list -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}
