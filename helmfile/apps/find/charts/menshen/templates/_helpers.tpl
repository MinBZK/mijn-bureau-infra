{{/*

SPDX-License-Identifier: EUPL-1.2
*/}}

{{/*
Return the proper menshen image name
*/}}
{{- define "menshen.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.menshen.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "menshen.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.menshen.image .Values.jwtKeys.image .Values.jwtKeys.kubectlImage) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "menshen.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name of the Secret that stores the menshen credentials
*/}}
{{- define "menshen.secretName" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Return the name of the ConfigMap with the setup script and spec
*/}}
{{- define "menshen.setupConfigMapName" -}}
{{- printf "%s-setup" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Return the name of the Secret holding the JWT signing keys (generated on the
cluster by the jwt-keys pre-install job)
*/}}
{{- define "menshen.jwtKeys.secretName" -}}
{{- default (printf "%s-jwt-keys" (include "common.names.fullname" .)) .Values.jwtKeys.existingSecret -}}
{{- end -}}

{{/*
Render the setup spec (services without secrets, rules) as JSON
*/}}
{{- define "menshen.setupSpecJson" -}}
{{- $services := list -}}
{{- range .Values.setup.services -}}
{{- $services = append $services (dict "name" .name "audienceId" .audienceId "clientId" .clientId "secretEnv" .secretEnv) -}}
{{- end -}}
{{- dict "services" $services "rules" .Values.setup.rules | toJson -}}
{{- end -}}
