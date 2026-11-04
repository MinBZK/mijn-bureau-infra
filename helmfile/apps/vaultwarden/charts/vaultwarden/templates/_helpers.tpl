{{/*

SPDX-License-Identifier: EUPL-1.2
*/}}

{{/*
Return the proper vaultwarden image name
*/}}
{{- define "vaultwarden.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.vaultwarden.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "vaultwarden.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.vaultwarden.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "vaultwarden.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name of the secret holding the admin token
*/}}
{{- define "vaultwarden.secretName" -}}
{{- default (include "common.names.fullname" .) .Values.vaultwarden.existingSecret -}}
{{- end -}}
