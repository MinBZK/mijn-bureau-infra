{{/*

SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper meet image name
*/}}
{{- define "meet.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.meet.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper meet image name
*/}}
{{- define "meet_backend.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.meet_backend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "meet.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.defaultInitContainers.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "meet.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.meet.image .Values.defaultInitContainers.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "meet_backend.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.meet_backend.image .Values.defaultInitContainers.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "meet.serviceAccountName" -}}
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
{{- define "meet.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "meet.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "meet.validateValues.foo" .) -}}
{{- $messages := append $messages (include "meet.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}
