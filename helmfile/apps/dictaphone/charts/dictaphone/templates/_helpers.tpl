{{/*

SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Transform a dictionary of environment variables into a list.
Usage: {{ include "dictaphone.env.transformDict" .Values.some.envVars }}
*/}}
{{- define "dictaphone.env.transformDict" -}}
{{- range $key, $value := . }}
- name: {{ $key | quote }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
Return the proper Dictaphone backend image name
*/}}
{{- define "dictaphone.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.backend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Dictaphone frontend image name
*/}}
{{- define "dictaphone.frontend.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.frontend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Dictaphone audio extractor image name
*/}}
{{- define "dictaphone.audioExtractor.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.audioExtractor.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Dictaphone S3 gateway image name
*/}}
{{- define "dictaphone.s3Gateway.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.s3Gateway.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "dictaphone.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.backend.image .Values.frontend.image .Values.audioExtractor.image .Values.s3Gateway.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "dictaphone.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name of the Secret that stores the Dictaphone credentials
*/}}
{{- define "dictaphone.secretName" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Return the name of the Secret that stores the Django superuser credentials
*/}}
{{- define "dictaphone.superuserSecretName" -}}
{{- printf "%s-superuser" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Full name for the backend
*/}}
{{- define "dictaphone.backend.fullname" -}}
{{ include "common.names.fullname" . }}-backend
{{- end -}}

{{/*
Full name for the frontend
*/}}
{{- define "dictaphone.frontend.fullname" -}}
{{ include "common.names.fullname" . }}-frontend
{{- end -}}

{{/*
Full name for the Celery worker
*/}}
{{- define "dictaphone.celery.fullname" -}}
{{ include "common.names.fullname" . }}-celery
{{- end -}}

{{/*
Full name for the audio extraction workers
*/}}
{{- define "dictaphone.audioExtractor.fullname" -}}
{{ include "common.names.fullname" . }}-audio-extractor
{{- end -}}

{{/*
Full name for the S3 gateway
*/}}
{{- define "dictaphone.s3Gateway.fullname" -}}
{{ include "common.names.fullname" . }}-s3-gateway
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "dictaphone.validateValues" -}}
{{- $messages := list -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}
