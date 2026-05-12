{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper Nextcloud image name
*/}}
{{- define "nextcloud.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "nextcloud.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.metrics.image ) "context" $) -}}
{{- end -}}

{{/*
Return the proper Nextcloud metrics exporter image name
*/}}
{{- define "nextcloud.metrics.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the name of the Secret holding the Nextcloud serverinfo metrics token.
*/}}
{{- define "nextcloud.metrics.secretName" -}}
{{- if .Values.metrics.auth.existingSecret -}}
{{- tpl .Values.metrics.auth.existingSecret $ -}}
{{- else -}}
{{- printf "%s-metrics-token" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "nextcloud.serviceAccountName" -}}
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
{{- define "nextcloud.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the Nextcloud secret.
*/}}
{{- define "nextcloud.secretName" -}}
{{- if .Values.auth.existingSecret -}}
{{- printf "%s" (tpl .Values.auth.existingSecret $) -}}
{{- else -}}
{{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Get the password key to be retrieved from Nextcloud secret.
*/}}
{{- define "nextcloud.secretPasswordKey" -}}
{{- if and .Values.auth.existingSecret .Values.auth.existingSecretPasswordKey -}}
{{- printf "%s" (tpl .Values.auth.existingSecretPasswordKey $) -}}
{{- else -}}
{{- printf "nextcloud-password" -}}
{{- end -}}
{{- end -}}

{{/*
Get the username key to be retrieved Nextcloud secret.
*/}}
{{- define "nextcloud.secretUsernameKey" -}}
{{- if and .Values.auth.existingSecret .Values.auth.existingSecretUsernameKey -}}
{{- printf "%s" (tpl .Values.auth.existingSecretUsernameKey $) -}}
{{- else -}}
{{- printf "nextcloud-username" -}}
{{- end -}}
{{- end -}}


{{/*
Get the SMTP secret.
*/}}
{{- define "smtp.secretName" -}}
{{- if .Values.mail.smtp.existingSecret -}}
{{- printf "%s" (tpl .Values.mail.smtp.existingSecret $) -}}
{{- else -}}
{{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Get the SMTP username key to be retrieved SMTP secret.
*/}}
{{- define "smtp.secretUsernameKey" -}}
{{- if and .Values.mail.smtp.existingSecret .Values.mail.smtp.existingSecretUsernameKey -}}
{{- printf "%s" (tpl .Values.mail.smtp.existingSecretUsernameKey $) -}}
{{- else -}}
{{- printf "smtp-username" -}}
{{- end -}}
{{- end -}}

{{/*
Get the SMTP password key to be retrieved from SMTP secret.
*/}}
{{- define "smtp.secretPasswordKey" -}}
{{- if and .Values.mail.smtp.existingSecret .Values.mail.smtp.existingSecretPasswordKey -}}
{{- printf "%s" (tpl .Values.mail.smtp.existingSecretPasswordKey $) -}}
{{- else -}}
{{- printf "nextcloud-password" -}}
{{- end -}}
{{- end -}}

{{/*
Return Nextcloud username
*/}}
{{- define "nextcloud.username" -}}
    {{- include "common.secrets.passwords.manage" (dict "secret" (include "nextcloud.secretName" .) "key" (include "nextcloud.secretUsernameKey" .) "providedValues" (list "auth.username") "length" 0 "skipB64enc" true "skipQuote" true "honorProvidedValues" true "context" $) -}}
{{- end }}

{{/*
Return Nextcloud password
*/}}
{{- define "nextcloud.password" -}}
    {{- include "common.secrets.passwords.manage" (dict "secret" (include "nextcloud.secretName" .) "key" (include "nextcloud.secretPasswordKey" .) "providedValues" (list "auth.password") "length" 10 "skipB64enc" true "skipQuote" true "honorProvidedValues" true "context" $) -}}
{{- end }}

{{/*
Return true if a secret object for Nextcloud should be created
*/}}
{{- define "nextcloud.createSecret" -}}
  {{- if or (not .Values.auth.existingSecret) (and .Values.mail.enabled .Values.mail.smtp.auth.username (not .Values.mail.smtp.auth.existingSecret)) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis secret name
*/}}
{{- define "nextcloud.redis.secretName" -}}
{{- if .Values.externalRedis.existingSecret }}
    {{- printf "%s" .Values.externalRedis.existingSecret -}}
{{- else -}}
    {{- printf "%s-externalredis" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the external redis password key
*/}}
{{- define "nextcloud.redis.secretPasswordKey" -}}
{{- if .Values.externalRedis.existingSecret -}}
  {{- default "password" .Values.externalRedis.ExistingSecretSecretPasswordKey }}
{{- else -}}
  {{- print "password" -}}
{{- end -}}
{{- end -}}

{{/*
Return the MinIO secret name
*/}}
{{- define "nextcloud.minio.secretName" -}}
{{- if .Values.externalMinio.existingSecret }}
    {{- printf "%s" .Values.externalMinio.existingSecret -}}
{{- else -}}
    {{- printf "%s-externalminio" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the external minio username
*/}}
{{- define "nextcloud.minio.secretUsernameKey" -}}
{{- if .Values.externalMinio.existingSecret -}}
  {{- default "username" .Values.externalMinio.existingSecretUsernameKey }}
{{- else -}}
  {{- print "username" -}}
{{- end -}}
{{- end -}}

{{/*
Return the external minio password
*/}}
{{- define "nextcloud.minio.secretPasswordKey" -}}
{{- if .Values.externalMinio.existingSecret -}}
  {{- default "password" .Values.externalMinio.existingSecretPasswordKey }}
{{- else -}}
  {{- print "password" -}}
{{- end -}}
{{- end -}}

{{/*
Return the database secret name
*/}}
{{- define "nextcloud.database.secretName" -}}
{{- if .Values.externalDatabase.existingSecret }}
    {{- printf "%s" .Values.externalDatabase.existingSecret -}}
{{- else -}}
    {{- printf "%s-externaldatabase" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the external database username
*/}}
{{- define "nextcloud.database.secretUsernameKey" -}}
{{- if .Values.externalDatabase.existingSecret -}}
  {{- default "username" .Values.externalDatabase.existingSecretUsernameKey }}
{{- else -}}
  {{- print "username" -}}
{{- end -}}
{{- end -}}

{{/*
Return the external database password
*/}}
{{- define "nextcloud.database.secretPasswordKey" -}}
{{- if .Values.externalDatabase.existingSecret -}}
  {{- default "password" .Values.externalDatabase.existingSecretPasswordKey }}
{{- else -}}
  {{- print "password" -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "nextcloud.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "nextcloud.validateValues.SMTPAuth" .) -}}
{{- $messages := append $messages (include "nextcloud.validateValues.PHPLimits" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/*
Validate SMTP configuration
*/}}
{{- define "nextcloud.validateValues.SMTPAuth" -}}
{{- if and .Values.mail.enabled (not .Values.mail.smtp.existingSecret) (not .Values.mail.smtp.username) -}}
    {{- fail "ERROR: When mail.enabled=true and no mail.smtp.existingSecret is provided, mail.smtp.username is required" -}}
{{- end -}}
{{- end -}}

{{/*
Convert a PHP memory-size string (e.g. "512M", "1G", "2048K", "1024")
to bytes as an integer string. PHP suffixes are case-insensitive and
binary (1K = 1024); leading/trailing whitespace is tolerated.
A plain integer with no suffix is treated as bytes (matches PHP).
"-1" (unlimited) maps to math.MaxInt64 so it always compares as the
largest possible value. Any other input — including Kubernetes-style
binary suffixes (Ki/Mi/Gi/Ti), the T suffix, internal whitespace, or
junk — fails the render with a clear error rather than being silently
misparsed as bytes.
*/}}
{{- define "nextcloud.phpLimitToBytes" -}}
{{- $s := . | toString | upper | trim -}}
{{- if eq $s "-1" -}}9223372036854775807
{{- else -}}
    {{- if not (regexMatch "^[0-9]+[KMG]?$" $s) -}}
        {{- fail (printf "ERROR: %q is not a valid PHP memory-size value. Expected an integer with optional suffix K, M, or G (PHP-style, binary). Kubernetes-style suffixes (Ki/Mi/Gi) are not accepted by PHP." .) -}}
    {{- end -}}
    {{- $num := regexFind "^[0-9]+" $s | atoi -}}
    {{- $suffix := regexReplaceAll "^[0-9]+" $s "" -}}
    {{- if eq $suffix "K" -}}{{ mul $num 1024 }}
    {{- else if eq $suffix "M" -}}{{ mul $num 1048576 }}
    {{- else if eq $suffix "G" -}}{{ mul $num 1073741824 }}
    {{- else -}}{{ $num }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate that phpMemoryLimit >= phpUploadLimit.
PHP cannot reliably process file uploads when memory_limit is smaller
than upload_max_filesize / post_max_size; Nextcloud preview generation,
server-side encryption, and DAV chunked operations need extra headroom
on top of that.
*/}}
{{- define "nextcloud.validateValues.PHPLimits" -}}
{{- if and .Values.phpMemoryLimit .Values.phpUploadLimit -}}
    {{- $memBytes := include "nextcloud.phpLimitToBytes" .Values.phpMemoryLimit | int64 -}}
    {{- $uploadBytes := include "nextcloud.phpLimitToBytes" .Values.phpUploadLimit | int64 -}}
    {{- if lt $memBytes $uploadBytes -}}
        {{- fail (printf "ERROR: phpMemoryLimit (%s) must be >= phpUploadLimit (%s) — PHP cannot process uploads larger than memory_limit." .Values.phpMemoryLimit .Values.phpUploadLimit) -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Add and enable apps
{{ include "nextcloud.addAndEnableApp" (dict "appName" "appName" "appTitle" "app title") -}}
*/}}
{{- define "nextcloud.addAndEnableApp" -}}
{{- if and (hasKey . "appName") (hasKey . "appTitle") -}}
{{- include "nextcloud.addAndEnableAppPreConfig" (dict "appName" .appName "appTitle" .appTitle) }}
{{- include "nextcloud.addAndEnableAppPostConfig" . }}
{{- end -}}
{{- end -}}

{{/*
Add and enable apps - Part before configuration
{{ include "nextcloud.addAndEnableAppPreConfig" (dict "appName" "appName" "appTitle" "app title") -}}
*/}}
{{- define "nextcloud.addAndEnableAppPreConfig" }}
{{- if and (hasKey . "appName") (hasKey . "appTitle") }}
{{ .appName }}.sh: |-
  #!/bin/bash

  echo "Waiting for NextCloud to be ready for {{ .appTitle }} setup..."
  counter=0
  while [ "$counter" -lt 60 ]; do
    if php /var/www/html/occ status | grep -q "installed: true"; then
      echo "NextCloud is ready, setting up {{ .appTitle }} app..."

      echo "Installing {{ .appTitle }} app..."
      if ! php /var/www/html/occ app:install {{ .appName }}; then
        echo "WARNING: Failed to install {{ .appTitle }} app (maybe already present)"
      else
        echo "{{ .appTitle }} app installation completed"
      fi

      echo "Enabling {{ .appTitle }} app..."
      if ! php /var/www/html/occ app:enable {{ .appName }}; then
        echo "WARNING: Failed to enable {{ .appTitle }} app"
      else
        echo "{{ .appTitle }} app enablement completed"
      fi

{{- end }}
{{- end }}

{{/*
Add and enable apps - Part after configuration
{{ include "nextcloud.addAndEnableAppPostConfig" $ -}}
*/}}
{{- define "nextcloud.addAndEnableAppPostConfig" }}
      break
    fi
    echo "Waiting for NextCloud... ($counter/60)"
    sleep 5
    counter=$((counter + 5))
  done
{{- end }}
