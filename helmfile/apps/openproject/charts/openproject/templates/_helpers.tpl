{{/*
Returns the OpenProject image to be used including the respective registry and image tag.
*/}}
{{- define "openproject.image" -}}
{{ .Values.image.registry }}/{{ .Values.image.repository }}{{ if .Values.image.sha256 }}@sha256:{{ .Values.image.sha256 }}{{ else }}:{{ .Values.image.tag }}{{ end }}
{{- end -}}

{{/*
Returns the OpenProject image pull secrets, if any are defined
*/}}
{{- define "openproject.imagePullSecrets" -}}
{{- if or .Values.imagePullSecrets .Values.global.imagePullSecrets }}
imagePullSecrets:
  {{- range (coalesce .Values.imagePullSecrets .Values.global.imagePullSecrets) }}
  - name: "{{ . }}"
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Returns extra volume definitons when defined as values.extraVolumes
*/}}
{{- define "openproject.extraVolumes" -}}
{{- if .Values.extraVolumes }}
{{ include "common.tplvalues.render" (dict "value" .Values.extraVolumes  "context" .) }}
{{- end }}
{{- end -}}

{{/*
Returns extra volume mounts definitons when defined as values.extraVolumeMounts
*/}}
{{- define "openproject.extraVolumeMounts" -}}
{{- if .Values.extraVolumeMounts }}
{{ include "common.tplvalues.render" (dict "value" .Values.extraVolumeMounts "context" .) }}
{{- end }}
{{- end -}}

{{/*
Yields the configured container security context if enabled.

Allows writing to the container file system in development mode
This way the OpenProject container works without mounted tmp volumes
which may not work correctly in local development clusters.
*/}}
{{- define "openproject.containerSecurityContext" }}
{{- if .Values.containerSecurityContext.enabled }}
securityContext:
  {{-
    mergeOverwrite
      (omit .Values.containerSecurityContext "enabled" | deepCopy)
      (dict "readOnlyRootFilesystem" (and
        (not .Values.develop)
        (get .Values.containerSecurityContext "readOnlyRootFilesystem")
      ))
    | toYaml
    | nindent 2
  }}
{{- end }}
{{- end }}

{{/* Yields the configured pod security context if enabled. */}}
{{- define "openproject.podSecurityContext" }}
{{- if .Values.podSecurityContext.enabled }}
securityContext:
  {{ omit .Values.podSecurityContext "enabled" | toYaml | nindent 2 | trim }}
{{- end }}
{{- end }}


{{- define "openproject.useTmpVolumes" -}}
{{- if ne .Values.openproject.useTmpVolumes nil -}}
  {{- .Values.openproject.useTmpVolumes -}}
{{- else -}}
  {{- (not .Values.develop) -}}
{{- end -}}
{{- end -}}

{{- define "openproject.tmpVolumeMounts" -}}
{{- if eq (include "openproject.useTmpVolumes" .) "true" }}
- mountPath: /tmp
  name: tmp
- mountPath: /app/tmp
  name: app-tmp
{{- end }}
{{- end -}}

{{- define "hocuspocus.tmpVolumeMounts" -}}
{{- if eq (include "openproject.useTmpVolumes" .) "true" }}
- mountPath: /tmp
  name: tmp
{{- end }}
{{- end -}}

{{- define "openproject.tmpVolumeSpec" -}}
{{- if eq (include "openproject.useTmpVolumes" .) "true" }}
- name: tmp
  # we can't use emptyDir due to the sticky bit issue
  # see: https://github.com/kubernetes/kubernetes/issues/110835
  ephemeral:
    volumeClaimTemplate:
      metadata:
        creationTimestamp: null
        {{- if .Values.openproject.tmpVolumesAnnotations }}
        annotations:
          {{ .Values.openproject.tmpVolumesAnnotations | toYaml }}
        {{- end }}
        {{- if .Values.openproject.tmpVolumesLabels }}
        labels:
          {{ .Values.openproject.tmpVolumesLabels | toYaml }}
        {{- end }}
      spec:
        accessModes: ["ReadWriteOnce"]
        {{- if or .Values.openproject.tmpVolumesStorageClassName .Values.persistence.storageClassName }}
        storageClassName: {{ coalesce .Values.openproject.tmpVolumesStorageClassName .Values.persistence.storageClassName }}
        {{- end }}
        resources:
          requests:
            storage: {{ .Values.openproject.tmpVolumesStorage }}
- name: app-tmp
  # we can't use emptyDir due to the sticky bit / world writable issue
  # see: https://github.com/kubernetes/kubernetes/issues/110835
  ephemeral:
    volumeClaimTemplate:
      metadata:
        creationTimestamp: null
        {{- if .Values.openproject.tmpVolumesAnnotations }}
        annotations:
          {{ .Values.openproject.tmpVolumesAnnotations | toYaml }}
        {{- end }}
        {{- if .Values.openproject.tmpVolumesLabels }}
        labels:
          {{ .Values.openproject.tmpVolumesLabels | toYaml }}
        {{- end }}
      spec:
        accessModes: ["ReadWriteOnce"]
        {{- if or .Values.openproject.tmpVolumesStorageClassName .Values.persistence.storageClassName }}
        storageClassName: {{ coalesce .Values.openproject.tmpVolumesStorageClassName .Values.persistence.storageClassName }}
        {{- end }}
        resources:
          requests:
            storage: {{ .Values.openproject.tmpVolumesStorage }}
{{- end }}
{{- end -}}

{{- define "openproject.envFrom" -}}
- secretRef:
    name: {{ include "common.names.fullname" . }}-core
{{- if .Values.openproject.oidc.enabled }}
- secretRef:
    name: {{ include "common.names.fullname" . }}-oidc
{{- end }}
{{- if .Values.s3.enabled }}
- secretRef:
    name: {{ include "common.names.fullname" . }}-s3
{{- end }}
{{- if .Values.s3.auth.existingSecret }}
- secretRef:
    name: {{ .Values.s3.auth.existingSecret }}
{{- end }}
{{- if eq .Values.openproject.cache.store "memcache" }}
- secretRef:
    name: {{ include "common.names.fullname" . }}-memcached
{{- end }}
{{- if .Values.environment }}
- secretRef:
    name: {{ include "common.names.fullname" . }}-environment
{{- end }}
{{- if .Values.openproject.extraEnvVarsSecret }}
- secretRef:
    name: {{ .Values.openproject.extraEnvVarsSecret }}
{{- end }}
{{- if .Values.openproject.oidc.extraOidcSealedSecret }}
- secretRef:
    name: {{ .Values.openproject.oidc.extraOidcSealedSecret }}
{{- end }}
{{- end }}

{{- define "openproject.env" -}}
{{- if .Values.metrics.enabled }}
- name: OPENPROJECT_METRICS_ENABLED
  value: "true"
{{- end }}
{{- if .Values.egress.tls.rootCA.fileName }}
- name: SSL_CERT_FILE
  value: "/etc/ssl/certs/custom-ca.pem"
{{- end }}
{{- if .Values.postgresql.auth.existingSecret }}
- name: OPENPROJECT_DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgresql.auth.existingSecret }}
      key: {{ .Values.postgresql.auth.secretKeys.userPasswordKey }}
{{- else if .Values.postgresql.auth.password }}
- name: OPENPROJECT_DB_PASSWORD
  value: {{ .Values.postgresql.auth.password }}
{{- else }}
- name: OPENPROJECT_DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) }}
      key: {{ .Values.postgresql.auth.secretKeys.userPasswordKey }}
{{- end }}
{{- end }}

{{- define "openproject.envChecksums" }}
# annotate pods with env value checksums so changes trigger re-deployments
{{/* If I knew how to map and reduce a range in helm I would do that and use a single checksum. But here we are. */}}
{{- range $suffix := list "core" "memcached" "oidc" "s3" "environment" }}
checksum/env-{{ $suffix }}: {{ include (print $.Template.BasePath "/secret_" $suffix ".yaml") $ | sha256sum }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "openproject.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
