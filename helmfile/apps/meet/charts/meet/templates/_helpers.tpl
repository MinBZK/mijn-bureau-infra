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
Return the proper agent metadata image name
*/}}
{{- define "meet.agentMetadata.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.agent_metadata.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper agent subtitles image name
*/}}
{{- define "meet.agentSubtitles.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.agent_subtitles.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper celery backend image name
*/}}
{{- define "meet.celeryBackend.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.celery_backend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper celery summarize image name
*/}}
{{- define "meet.celerySummarize.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.celery_summarize.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper celery transcribe image name
*/}}
{{- define "meet.celeryTranscribe.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.celery_transcribe.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "meet.agentMetadata.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.agent_metadata.image) "context" $) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "meet.agentSubtitles.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.agent_subtitles.image) "context" $) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "meet.celeryBackend.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.celery_backend.image) "context" $) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "meet.celerySummarize.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.celery_summarize.image) "context" $) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "meet.celeryTranscribe.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.celery_transcribe.image) "context" $) -}}
{{- end -}}

{{/*
Full names for the additional meet components
*/}}
{{- define "meet.agentMetadata.fullname" -}}
{{ include "common.names.fullname" . }}-agent-metadata
{{- end -}}

{{- define "meet.agentSubtitles.fullname" -}}
{{ include "common.names.fullname" . }}-agent-subtitles
{{- end -}}

{{- define "meet.celeryBackend.fullname" -}}
{{ include "common.names.fullname" . }}-celery-backend
{{- end -}}

{{- define "meet.celerySummarize.fullname" -}}
{{ include "common.names.fullname" . }}-celery-summarize
{{- end -}}

{{- define "meet.celeryTranscribe.fullname" -}}
{{ include "common.names.fullname" . }}-celery-transcribe
{{- end -}}

{{/*
Return the proper summary API image name
*/}}
{{- define "meet.summaryApi.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.summary_api.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "meet.summaryApi.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.summary_api.image) "context" $) -}}
{{- end -}}

{{- define "meet.summaryApi.fullname" -}}
{{ include "common.names.fullname" . }}-summary
{{- end -}}

{{/*
Transform a dictionary of environment variables into a list of EnvVar objects.
Usage: {{ include "meet.env.transformDict" .Values.component.envVars }}
*/}}
{{- define "meet.env.transformDict" -}}
{{- range $key, $value := . }}
- name: {{ $key | quote }}
{{- if $value | kindIs "map" }}
  valueFrom: {{ $value | toYaml | nindent 4 }}
{{- else }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Render the configured environment variables for a meet component.
Usage: {{ include "meet.common.env" (list . .Values.component) }}
*/}}
{{- define "meet.common.env" -}}
{{- $topLevelScope := index . 0 -}}
{{- $workerScope := index . 1 -}}
{{- include "meet.env.transformDict" (default (dict) $workerScope.envVars) -}}
{{- end -}}

{{/*
Return the name of the Secret that stores the meet credentials
*/}}
{{- define "meet.secretName" -}}
{{- include "common.names.fullname" . -}}
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
