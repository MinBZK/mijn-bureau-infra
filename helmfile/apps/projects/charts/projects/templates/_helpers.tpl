{{/*

SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper Projects image name
*/}}
{{- define "projects.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.projects.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "projects.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.projects.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "projects.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name of the Secret that stores the Projects credentials
*/}}
{{- define "projects.secretName" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "projects.validateValues" -}}
{{- $messages := list -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}
