{{/*
SPDX-License-Identifier: EUPL-1.2
*/}}

{{/*
Return the ketesa container image
*/}}
{{- define "ketesa.image" -}}
{{- printf "%s/%s:%s" (coalesce .Values.image.registry .Values.global.imageRegistry | default "ghcr.io") .Values.image.repository .Values.image.tag -}}
{{- end -}}

{{/*
Render the container resources from either explicit values or the
Bitnami-compatible resourcesPreset value used by the environment files.
*/}}
{{- define "ketesa.resources" -}}
{{- if .Values.resources -}}
{{- toYaml .Values.resources -}}
{{- else if ne (default "none" .Values.resourcesPreset) "none" -}}
{{- include "common.resources.preset" (dict "type" .Values.resourcesPreset) -}}
{{- else -}}
{}
{{- end -}}
{{- end -}}

{{/*
Path the static-web-server image serves from. config.json has to live in this
directory for the SPA to pick it up at /config.json.
*/}}
{{- define "ketesa.webRoot" -}}
/home/sws/public
{{- end -}}
