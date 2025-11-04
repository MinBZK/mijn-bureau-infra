{{/*

SPDX-License-Identifier: EUPL-1.2
*/}}

{{/*
Full name for backend
*/}}
{{- define "bureaublad.backend.fullname" -}}
{{ include "common.names.fullname" . }}-backend
{{- end -}}

{{/*
Full name for frontend
*/}}
{{- define "bureaublad.frontend.fullname" -}}
{{ include "common.names.fullname" . }}-frontend
{{- end -}}

{{/*
Return the proper backend image name
*/}}
{{- define "bureaublad.backend.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.backend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper frontend image name
*/}}
{{- define "bureaublad.frontend.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.frontend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "bureaublad.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.backend.image .Values.frontend.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "bureaublad.serviceAccountName" -}}
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
{{- define "bureaublad.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "bureaublad.validateValues" -}}
{{- $messages := list -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/*
transform dictionary of environment variables
Usage : {{ include "bureaublad.env.transformDict" .Values.envVars }}

Example:
envVars:
  # Using simple strings as env vars
  ENV_VAR_NAME: "envVar value"
  # Using a value from a configMap
  ENV_VAR_FROM_CM:
    configMapKeyRef:
      name: cm-name
      key: "key_in_cm"
  # Using a value from a secret
  ENV_VAR_FROM_SECRET:
    secretKeyRef:
      name: secret-name
      key: "key_in_secret"
*/}}
{{- define "bureaublad.env.transformDict" -}}
{{- range $key, $value := . }}
- name: {{ $key | quote }}
{{- if $value | kindIs "map" }}
  valueFrom: {{ $value | toYaml | nindent 4 }}
{{- else }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}


{{/*
bureaublad env vars
*/}}
{{- define "bureaublad.common.env" -}}
{{- $topLevelScope := index . 0 -}}
{{- $workerScope := index . 1 -}}
{{- include "bureaublad.env.transformDict" $workerScope.envVars -}}
{{- end }}
