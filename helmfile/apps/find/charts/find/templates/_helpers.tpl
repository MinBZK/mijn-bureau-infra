{{/*

SPDX-License-Identifier: EUPL-1.2
*/}}

{{/*
Return the proper find image name
*/}}
{{- define "find.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.find.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "find.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.find.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "find.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name of the Secret that stores the find credentials
*/}}
{{- define "find.secretName" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Return the name of the ConfigMap with the setup script
*/}}
{{- define "find.setupConfigMapName" -}}
{{- printf "%s-setup" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Render the registered services as a {"name": "token"} JSON object
*/}}
{{- define "find.servicesJson" -}}
{{- $services := dict -}}
{{- range .Values.services -}}
{{- $_ := set $services .name .token -}}
{{- end -}}
{{- $services | toJson -}}
{{- end -}}
