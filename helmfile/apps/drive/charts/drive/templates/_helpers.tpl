{{/*

SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper drive image name
*/}}
{{- define "drive.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.drive.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper drive image name
*/}}
{{- define "drive_frontend.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.drive_frontend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "drive.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.defaultInitContainers.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "drive.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.drive.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "drive.serviceAccountName" -}}
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
{{- define "drive.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "drive.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "drive.validateValues.foo" .) -}}
{{- $messages := append $messages (include "drive.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}
