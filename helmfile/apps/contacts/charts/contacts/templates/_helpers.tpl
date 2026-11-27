{{/*
Expand the name of the chart.
*/}}
{{- define "contacts.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "contacts.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "contacts.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
contacts.labels
*/}}
{{- define "contacts.labels" -}}
helm.sh/chart: {{ include "contacts.chart" . }}
{{ include "contacts.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: contacts
{{- end }}

{{/*
Selector labels
*/}}
{{- define "contacts.selectorLabels" -}}
app.kubernetes.io/name: {{ include "contacts.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
transform dictionnary of environment variables
Usage : {{ include "contacts.env.transformDict" .Values.envVars }}

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
{{- define "contacts.env.transformDict" -}}
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
contacts env vars
*/}}
{{- define "contacts.common.env" -}}
{{- $topLevelScope := index . 0 -}}
{{- $workerScope := index . 1 -}}
{{- include "contacts.env.transformDict" $workerScope.envVars -}}
{{- end }}

{{/*
Common labels

Requires array with top level scope and component name
*/}}
{{- define "contacts.common.labels" -}}
{{- $topLevelScope := index . 0 -}}
{{- $component := index . 1 -}}
{{- include "contacts.labels" $topLevelScope }}
app.kubernetes.io/component: {{ $component }}
{{- end }}

{{/*
Common selector labels

Requires array with top level scope and component name
*/}}
{{- define "contacts.common.selectorLabels" -}}
{{- $topLevelScope := index . 0 -}}
{{- $component := index . 1 -}}
{{- include "contacts.selectorLabels" $topLevelScope }}
app.kubernetes.io/component: {{ $component }}
{{- end }}

{{- define "contacts.probes.abstract" -}}
{{- if .exec -}}
exec:
{{- toYaml .exec | nindent 2 }}
{{- else if .tcpSocket -}}
tcpSocket:
{{- toYaml .tcpSocket | nindent 2 }}
{{- else -}}
httpGet:
  path: {{ .path }}
  port: {{ .targetPort }}
{{- end }}
initialDelaySeconds: {{ .initialDelaySeconds | eq nil | ternary 0 .initialDelaySeconds }}
timeoutSeconds: {{ .timeoutSeconds | eq nil | ternary 1 .timeoutSeconds }}
{{- end }}

{{/*
Full name for the backend

Requires top level scope
*/}}
{{- define "contacts.backend.fullname" -}}
{{ include "contacts.fullname" . }}-backend
{{- end }}

{{/*
Full name for the frontend

Requires top level scope
*/}}
{{- define "contacts.frontend.fullname" -}}
{{ include "contacts.fullname" . }}-frontend
{{- end }}


{{/*
Full name for the Dramatiq worker

Requires top level scope
*/}}
{{- define "contacts.worker.fullname" -}}
{{ include "contacts.fullname" . }}-worker
{{- end }}

{{/*
Registry-aware image reference. Prefers scope (per-component) image settings,
falls back to the top-level image settings.
Usage: {{ include "contacts.image" (dict "scope" .Values.backend.image "root" .) }}
*/}}
{{- define "contacts.image" -}}
{{- $img := .scope | default dict -}}
{{- $root := .root.Values.image | default dict -}}
{{- $registry := $img.registry | default $root.registry -}}
{{- $repository := $img.repository | default $root.repository -}}
{{- $tag := $img.tag | default $root.tag -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $repository $tag | quote -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag | quote -}}
{{- end -}}
{{- end -}}

{{/*
Name of the ServiceAccount to use.
*/}}
{{- define "contacts.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "contacts.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Usage : {{ include "contacts.secret.dockerconfigjson.name" (dict "fullname" (include "contacts.fullname" .) "imageCredentials" .Values.path.to.the.image1) }}
*/}}
{{- define "contacts.secret.dockerconfigjson.name" }}
{{- if (default (dict) .imageCredentials).name }}{{ .imageCredentials.name }}{{ else }}{{ .fullname | trunc 63 | trimSuffix "-" }}-dockerconfig{{ end -}}
{{- end }}

{{/*
Usage : {{ include "contacts.secret.dockerconfigjson" (dict "fullname" (include "contacts.fullname" .) "imageCredentials" .Values.path.to.the.image1) }}
*/}}
{{- define "contacts.secret.dockerconfigjson" }}
{{- if .imageCredentials -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ template "contacts.secret.dockerconfigjson.name" (dict "fullname" .fullname "imageCredentials" .imageCredentials) }}
  annotations:
    "helm.sh/hook": pre-install,pre-upgrade
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": before-hook-creation
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: {{ template "contacts.secret.dockerconfigjson.data" .imageCredentials }}
{{- end -}}
{{- end }}
