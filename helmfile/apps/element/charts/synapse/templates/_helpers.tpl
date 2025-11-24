{{/*

SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Create a default fully qualified app name for Synapse master objects
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "synapse.master.fullname" -}}
  {{- $fullname := include "common.names.fullname" . -}}
  {{- ternary (printf "%s-%s" $fullname .Values.master.name | trunc 63 | trimSuffix "-") $fullname (eq .Values.architecture "replication") -}}
{{- end -}}

{{/*
Create a default fully qualified app name for replication objects
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "synapse.replication.fullname" -}}
  {{- $fullname := include "common.names.fullname" . -}}
  {{- printf "%s-%s" $fullname "replication" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for Synapse worker objects
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "synapse.worker.fullname" -}}
  {{- printf "%s-%s" (include "common.names.fullname" .global) (.worker | replace "_" "-") | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper synapse image name
*/}}
{{- define "synapse.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{- define "synapse_job.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.job.InitContainers.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "synapse.volumePermissions.image" -}}
  {{- include "common.images.image" ( dict "imageRoot" .Values.defaultInitContainers.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "synapse.imagePullSecrets" -}}
  {{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.defaultInitContainers.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "synapse.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
  {{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
  {{- end -}}
{{- end -}}

{{/*
Return true if cert-manager required annotations for TLS signed certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
*/}}
{{- define "synapse.ingress.certManagerRequest" -}}
  {{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "synapse.validateValues" -}}
  {{- $messages := list -}}
  {{- $messages := append $messages (include "synapse.validateValues.architecture" .) -}}
  {{- $messages := append $messages (include "synapse.validateValues.database.type" .) -}}
  {{- $messages := without $messages "" -}}
  {{- $message := join "\n" $messages -}}

  {{- if $message -}}
    {{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
  {{- end -}}
{{- end -}}

{{/* Validate values of Synapse - must provide a valid architecture */}}
{{- define "synapse.validateValues.architecture" -}}
  {{- if and (ne .Values.architecture "monolith") (ne .Values.architecture "replication") -}}
    synapse: architecture
    Invalid architecture selected. Valid values are "monolith" and
    "replication". Please set a valid architecture (--set architecture="xxxx")
    WARNING: "replication" is not yet implemented.
  {{- end -}}
{{- end -}}

{{/* Validate values of Synapse - must provide a valid database type */}}
{{- define "synapse.validateValues.database.type" -}}
  {{- if and (ne .Values.synapse.database.name "psycopg2") (ne .Values.synapse.database.name "sqlite3") -}}
    synapse: database name
    Invalid database name selected. Valid values are "psycopg2" and
    "sqlite3". Please set a valid database type (--set synapse.database.name="xxxx")
  {{- end -}}
{{- end -}}

{{/* Validate values of Synapse - must provide a valid database type */}}
{{- define "synapse.validateValues.architecture.redisReplication" -}}
  {{- if and (eq .Values.architecture "replication") (not .Values.synapse.redis.enabled) -}}
    synapse: replication architecture without redis
    When using replication architecture, redis is required.
  {{- end -}}
{{- end -}}
