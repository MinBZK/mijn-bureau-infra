{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper grist image name
*/}}
{{- define "grist.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "grist.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.defaultInitContainers.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "grist.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "grist.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the PVC to use
*/}}
{{- define "grist.pvcName" -}}
{{- if .Values.persistence.existingClaim -}}
    {{ .Values.persistence.existingClaim }}
{{- else -}}
    {{ printf "data-%s" (include "common.names.fullname" .) }}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "grist.validateValues" -}}
  {{- $messages := list -}}
  {{- $messages := append $messages (include "grist.validateValues.externalDatabase" .) -}}
  {{- $messages := append $messages (include "grist.validateValues.externalRedis" .) -}}
  {{- $messages := append $messages (include "grist.validateValues.externalMinio" .) -}}
  {{- $messages := append $messages (include "grist.validateValues.oidc" .) -}}
  {{- $messages := without $messages "" -}}
  {{- $message := join "\n" $messages -}}

  {{- if $message -}}
    {{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
  {{- end -}}
{{- end -}}

{{/*
Validate values of Grist - External Database Configuration
*/}}
{{- define "grist.validateValues.externalDatabase" -}}
  {{- if or (not .Values.externalDatabase.type) (not .Values.externalDatabase.host) (not .Values.externalDatabase.username) (not .Values.externalDatabase.password) (not .Values.externalDatabase.database) -}}
    grist: externalDatabase
    You must provide external database configuration when running Grist.
    Please set the following required values:
      - externalDatabase.type (e.g., "postgres" or "sqlite")
      - externalDatabase.host (database hostname)
      - externalDatabase.username (database username)
      - externalDatabase.password (database password)
      - externalDatabase.database (database name)

    Example:
      externalDatabase:
        type: "postgres"
        host: "postgresql.example.com"
        username: "grist"
        password: "your-password"
        database: "grist"
        port: 5432
  {{- end -}}
{{- end -}}

{{/*
Validate values of Grist - External Redis Configuration
*/}}
{{- define "grist.validateValues.externalRedis" -}}
  {{- if or (not .Values.externalRedis.host) (not .Values.externalRedis.port) (not .Values.externalRedis.password) -}}
    grist: externalRedis
    You must provide external Redis configuration when running Grist.
    Please set the following required values:
      - externalRedis.host (Redis hostname)
      - externalRedis.port (Redis port, typically 6379)
      - externalRedis.password (Redis password)

    Example:
      externalRedis:
        host: "redis.example.com"
        port: 6379
        password: "your-redis-password"
  {{- end -}}
{{- end -}}

{{/*
Validate values of Grist - External MinIO Configuration
*/}}
{{- define "grist.validateValues.externalMinio" -}}
  {{- if or (not .Values.externalMinio.endpoint) (not .Values.externalMinio.port) (not .Values.externalMinio.accessKey) (not .Values.externalMinio.secretKey) (not .Values.externalMinio.bucket) -}}
    grist: externalMinio
    You must provide external MinIO/S3 configuration when running Grist.
    Please set the following required values:
      - externalMinio.endpoint (MinIO/S3 endpoint)
      - externalMinio.port (MinIO/S3 port, typically 9000)
      - externalMinio.accessKey (access key/username)
      - externalMinio.secretKey (secret key/password)
      - externalMinio.bucket (bucket name for document storage)

    Example:
      externalMinio:
        endpoint: "minio.example.com"
        port: 9000
        accessKey: "your-access-key"
        secretKey: "your-secret-key"
        bucket: "grist-docs"
        useSSL: false
  {{- end -}}
{{- end -}}

{{/*
Optional: Validate values of Grist - OIDC Configuration
*/}}
{{- define "grist.validateValues.oidc" -}}
  {{- if .Values.auth.enabled -}}
    {{- if or (not .Values.auth.oidcIdpIssuer) (not .Values.auth.oidcIdpClientId) (not .Values.auth.oidcIdpClientSecret) -}}
    grist: OIDC configuration
    When OIDC is enabled (auth.enabled=true), you must provide:
      - auth.oidcIdpIssuer (OIDC provider issuer URL)
      - auth.oidcIdpClientId (OIDC client ID)
      - auth.oidcIdpClientSecret (OIDC client secret)

    Example:
      auth:
        enabled: true
        oidcIdpIssuer: "https://auth.example.com/realms/myrealm"
        oidcIdpClientId: "grist-client"
        oidcIdpClientSecret: "your-client-secret"
    {{- end -}}
  {{- end -}}
{{- end -}}
