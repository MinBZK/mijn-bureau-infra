{{/*

SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper keycloak-config-cli image name
*/}}
{{- define "keycloak-config-cli.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "chart" .Chart) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "keycloak-config-cli.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list (dict "pullSecrets" .Values.imagePullSecrets)) "context" $) -}}
{{- end -}}
