{{/*

SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "mas.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mas.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Return the proper MAS image name
*/}}
{{- define "mas.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper kubectl image name (hook Jobs)
*/}}
{{- define "mas.kubectl.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.keygenJob.kubectl.image "global" (dict)) }}
{{- end -}}

{{/*
Return the proper shell (busybox) image name (hook Jobs)
*/}}
{{- define "mas.shell.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.keygenJob.shell.image "global" (dict)) }}
{{- end -}}

{{/*
Return the proper database bootstrap (PostgreSQL) image name
*/}}
{{- define "mas.databaseBootstrap.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.databaseBootstrap.image "global" (dict)) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "mas.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.keygenJob.kubectl.image .Values.keygenJob.shell.image .Values.databaseBootstrap.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "mas.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mas.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret managed by the keygen hook Job (encryption secret, signing
key, matrix shared secret and OAuth client secrets)
*/}}
{{- define "mas.generatedSecretName" -}}
{{- printf "%s-secrets" (include "mas.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Name of the ConfigMap holding the non-sensitive MAS configuration (http block)
*/}}
{{- define "mas.configMapName" -}}
{{- printf "%s-config" (include "mas.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
