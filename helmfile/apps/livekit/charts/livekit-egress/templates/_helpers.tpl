{{/*
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper egress image name
*/}}
{{- define "livekit-egress.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.egress.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper init container image name
*/}}
{{- define "livekit-egress.dirsInitImage" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.egress.dirsInitContainer.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "livekit-egress.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.egress.image .Values.egress.dirsInitContainer.image) "context" $) -}}
{{- end -}}

{{/*
Return the name of the Secret that stores the egress configuration
*/}}
{{- define "livekit-egress.secretName" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "livekit-egress.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}
