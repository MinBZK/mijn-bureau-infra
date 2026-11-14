{{/*
SPDX-License-Identifier: EUPL-1.2
*/}}

{{/*
Return the element-call container image
*/}}
{{- define "element-call.image" -}}
{{- printf "%s/%s:%s" (coalesce .Values.image.registry .Values.global.imageRegistry | default "ghcr.io") .Values.image.repository .Values.image.tag -}}
{{- end -}}

{{/*
Render the container resources from either explicit values or the
Bitnami-compatible resourcesPreset value used by the environment files.
*/}}
{{- define "element-call.resources" -}}
{{- if .Values.resources -}}
{{- toYaml .Values.resources -}}
{{- else if ne (default "none" .Values.resourcesPreset) "none" -}}
{{- include "common.resources.preset" (dict "type" .Values.resourcesPreset) -}}
{{- else -}}
{}
{{- end -}}
{{- end -}}
