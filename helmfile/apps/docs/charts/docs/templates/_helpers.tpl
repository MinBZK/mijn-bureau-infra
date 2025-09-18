{{/*

SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Full name for backend
*/}}
{{- define "docs.backend.fullname" -}}
{{ include "common.names.fullname" . }}-backend
{{- end -}}

{{/*
Full name for theme customizations
*/}}
{{- define "docs.theme.fullname" -}}
{{ include "common.names.fullname" . }}-theme
{{- end -}}

{{/*
Full name for frontend
*/}}
{{- define "docs.frontend.fullname" -}}
{{ include "common.names.fullname" . }}-frontend
{{- end -}}

{{/*
Full name for the yProvider
*/}}
{{- define "docs.yProvider.fullname" -}}
{{ include "common.names.fullname" . }}-y-provider
{{- end -}}

{{/*
Full name for Celery Worker
*/}}
{{- define "docs.celery.worker.fullname" -}}
{{ include "common.names.fullname" . }}-celery-worker
{{- end -}}

{{/*
Return the proper frontend image name
*/}}
{{- define "docs.frontend.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.frontend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper backend image name
*/}}
{{- define "docs.backend.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.backend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper yProvider image name
*/}}
{{- define "docs.yProvider.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.yProvider.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper celery worker image name
*/}}
{{- define "docs.celery.worker.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.backend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "docs.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.defaultInitContainers.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "docs.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.frontend.image .Values.backend.image .Values.yProvider.image .Values.defaultInitContainers.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "docs.serviceAccountName" -}}
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
{{- define "docs.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "docs.validateValues" -}}
{{- $messages := list -}}
{{/*{{- $messages := append $messages (include "docs.validateValues.foo" .) -}}*/}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/*
Base URL for the deployment
*/}}
{{- define "docs.baseUrl" -}}
{{- printf "http%s://%s" ( ternary "s" "" .Values.ingress.tls ) .Values.ingress.hostname -}}
{{- end -}}
