{{/*

SPDX-License-Identifier: EUPL-1.2
*/}}

{{/*
Return the proper backend image name
*/}}
{{- define "messages.backend.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.backend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper worker image name
*/}}
{{- define "messages.worker.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.worker.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper frontend image name
*/}}
{{- define "messages.frontend.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.frontend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper MTA image name
*/}}
{{- define "messages.mta.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.mta.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "messages.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.backend.image .Values.worker.image .Values.frontend.image .Values.mta.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "messages.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name of the Secret that stores the Messages credentials
*/}}
{{- define "messages.secretName" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Return the name of the Secret that stores the superuser credentials
*/}}
{{- define "messages.superuserSecretName" -}}
{{- printf "%s-superuser" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Return the internal backend URL
*/}}
{{- define "messages.backendUrl" -}}
{{- printf "http://%s-backend:%v" (include "common.names.fullname" .) .Values.service.ports.http -}}
{{- end -}}

{{/*
Return the internal frontend backend server
*/}}
{{- define "messages.frontendBackendServer" -}}
{{- if .Values.frontend.backendServer -}}
{{- .Values.frontend.backendServer -}}
{{- else -}}
{{- printf "%s-backend:%v" (include "common.names.fullname" .) .Values.service.ports.http -}}
{{- end -}}
{{- end -}}

{{/*
Return the object store URL
*/}}
{{- define "messages.objectStoreUrl" -}}
{{- .Values.externalObjectStore.endpoint -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "messages.validateValues" -}}
{{- $messages := list -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}
{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}
