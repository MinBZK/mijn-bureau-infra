{{/*
SPDX-License-Identifier: Apache-2.0
*/}}

{{/*
Return the SeaweedFS image name.
*/}}
{{- define "seaweedfs.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the image pull secrets.
*/}}
{{- define "seaweedfs.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use.
*/}}
{{- define "seaweedfs.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Standard labels, plus the component/part-of pair used by app NetworkPolicies.
Usage: {{- include "seaweedfs.labels" . | nindent 4 }}
*/}}
{{- define "seaweedfs.labels" -}}
{{- include "common.labels.standard" (dict "customLabels" .Values.commonLabels "context" .) }}
app.kubernetes.io/component: seaweedfs
app.kubernetes.io/part-of: seaweedfs
{{- end -}}

{{/*
Selector labels. Kept stable: they must not change between upgrades.
*/}}
{{- define "seaweedfs.matchLabels" -}}
{{- include "common.labels.matchLabels" (dict "customLabels" .Values.commonLabels "context" .) }}
app.kubernetes.io/component: seaweedfs
{{- end -}}

{{/*
Pod labels: matchLabels merged with user supplied server.podLabels.
*/}}
{{- define "seaweedfs.podLabels" -}}
{{- $labels := include "common.tplvalues.merge" (dict "values" (list .Values.server.podLabels .Values.commonLabels) "context" .) -}}
{{- include "common.labels.standard" (dict "customLabels" $labels "context" .) }}
app.kubernetes.io/component: seaweedfs
app.kubernetes.io/part-of: seaweedfs
{{- end -}}

{{/*
Container resources: explicit resources win, otherwise render the preset.
*/}}
{{- define "seaweedfs.resources" -}}
{{- if .Values.server.resources -}}
{{- toYaml .Values.server.resources -}}
{{- else if and .Values.server.resourcesPreset (ne .Values.server.resourcesPreset "none") -}}
{{- include "common.resources.preset" (dict "type" .Values.server.resourcesPreset) -}}
{{- end -}}
{{- end -}}

{{/*
Name of the Secret holding the S3 credentials.
*/}}
{{- define "seaweedfs.secretName" -}}
{{- default (include "common.names.fullname" .) .Values.auth.existingSecret -}}
{{- end -}}

{{/*
Name of the persistent volume claim.
*/}}
{{- define "seaweedfs.pvcName" -}}
{{- default (printf "%s-data" (include "common.names.fullname" .)) .Values.persistence.existingClaim -}}
{{- end -}}
