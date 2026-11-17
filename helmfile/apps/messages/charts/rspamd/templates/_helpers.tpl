{{/*

SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper rspamd image name
*/}}
{{- define "rspamd.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.rspamd.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "rspamd.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.rspamd.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "rspamd.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}
