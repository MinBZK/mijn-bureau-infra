{{/*

SPDX-License-Identifier: EUPL-1.2
*/}}

{{/*
Return the proper backend image name
*/}}
{{- define "calendars.backend.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.backend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper frontend image name
*/}}
{{- define "calendars.frontend.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.frontend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper CalDAV image name
*/}}
{{- define "calendars.caldav.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.caldav.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "calendars.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.backend.image .Values.frontend.image .Values.caldav.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "calendars.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name of the Secret that stores the calendars credentials
*/}}
{{- define "calendars.secretName" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Return the name of the Secret that stores the superuser credentials
*/}}
{{- define "calendars.superuserSecretName" -}}
{{- printf "%s-superuser" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Return true if cert-manager required annotations for TLS signed certificates
are set in the Ingress annotations
*/}}
{{- define "calendars.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "calendars.validateValues" -}}
{{- $messages := list -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}
{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}
