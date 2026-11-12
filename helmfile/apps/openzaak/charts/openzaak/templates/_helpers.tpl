{{/*

SPDX-License-Identifier: EUPL-1.2
*/}}

{{/*
Return the proper Open Zaak image name. The celery and celeryBeat images
default to the web image when their own image values are empty.
*/}}
{{- define "openzaak.app.image" -}}
{{- $imageRoot := .Values.web.image -}}
{{ include "common.images.image" (dict "imageRoot" $imageRoot "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper nginx image name
*/}}
{{- define "openzaak.nginx.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.nginx.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "openzaak.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.web.image .Values.celery.image .Values.celeryBeat.image .Values.nginx.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "openzaak.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name of the Secret that stores the Open Zaak credentials
*/}}
{{- define "openzaak.secretName" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Return the name of the Secret that stores the superuser credentials
*/}}
{{- define "openzaak.superuserSecretName" -}}
{{- printf "%s-superuser" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Return the name of the default catalogus fixture ConfigMap
*/}}
{{- define "openzaak.fixturesConfigMapName" -}}
{{- printf "%s-fixtures" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Return the name of the nginx configuration ConfigMap
*/}}
{{- define "openzaak.nginxConfigMapName" -}}
{{- printf "%s-nginx" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Return the internal web (uwsgi) service name
*/}}
{{- define "openzaak.webServiceName" -}}
{{- printf "%s-web" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Pod affinity co-locating the pods on a single node. The media PVC is
ReadWriteOnce (single-node attach for RBD volumes), so every pod that mounts
it must land on the same node.
*/}}
{{- define "openzaak.podAffinity" -}}
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels: {{- include "common.labels.matchLabels" ( dict "customLabels" .Values.commonLabels "context" $ ) | nindent 10 }}
      topologyKey: kubernetes.io/hostname
{{- end -}}

{{/*
Return the name of the media PVC
*/}}
{{- define "openzaak.mediaPvcName" -}}
{{- if .Values.persistence.media.existingClaim -}}
{{- .Values.persistence.media.existingClaim -}}
{{- else -}}
{{- printf "%s-media" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}
