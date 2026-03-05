{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Generate backend entry that is compatible with all Kubernetes API versions.

Usage:
{{ include "common.ingress.backend" (dict "serviceName" "backendName" "servicePort" "backendPort" "context" $) }}

Params:
  - serviceName - String. Name of an existing service backend
  - servicePort - String/Int. Port name (or number) of the service. It will be translated to different yaml depending if it is a string or an integer.
  - context - Dict - Required. The context for the template evaluation.
*/}}
{{- define "common.ingress.backend" -}}
service:
  name: {{ .serviceName }}
  port:
    {{- if typeIs "string" .servicePort }}
    name: {{ .servicePort }}
    {{- else if or (typeIs "int" .servicePort) (typeIs "float64" .servicePort) }}
    number: {{ .servicePort | int }}
    {{- end }}
{{- end -}}

{{/*
Generate a Gateway API HTTPRoute parentRef entry.

Usage:
{{ include "common.httproute.parentRef" .Values.cluster.gateway }}

Params (dict with keys):
  - name: Gateway name
  - namespace: Gateway namespace (optional)
*/}}
{{- define "common.httproute.parentRef" -}}
- name: {{ .name }}
  {{- if .namespace }}
  namespace: {{ .namespace }}
  {{- end }}
  sectionName: https
{{- end -}}

{{/*
Generate a ResponseHeaderModifier filter block for HSTS.
Omitted entirely when cluster.tls.selfSigned is true — browsers cannot satisfy
HSTS with self-signed certificates, and since domains don't switch between
self-signed and real certs there is no cached HSTS state to worry about.
*/}}
{{- define "common.httproute.hstsFilter" -}}
{{- $selfSigned := (((.Values.cluster | default dict).tls | default dict).selfSigned | default false) }}
{{- if not $selfSigned }}
- type: ResponseHeaderModifier
  responseHeaderModifier:
    set:
      - name: Strict-Transport-Security
        value: "max-age=31536000; includeSubDomains; preload"
{{- end }}
{{- end -}}

{{/*
Generate a ResponseHeaderModifier filter block for media routes (HSTS + restrictive CSP).
HSTS is omitted when cluster.tls.selfSigned is true; CSP is always applied.
*/}}
{{- define "common.httproute.secureMediaFilter" -}}
{{- $selfSigned := (((.Values.cluster | default dict).tls | default dict).selfSigned | default false) }}
- type: ResponseHeaderModifier
  responseHeaderModifier:
    set:
      {{- if not $selfSigned }}
      - name: Strict-Transport-Security
        value: "max-age=31536000; includeSubDomains; preload"
      {{- end }}
      - name: Content-Security-Policy
        value: "default-src 'none'"
{{- end -}}

{{/*
Return true if cert-manager required annotations for TLS signed
certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
Usage:
{{ include "common.ingress.certManagerRequest" ( dict "annotations" .Values.path.to.the.ingress.annotations ) }}
*/}}
{{- define "common.ingress.certManagerRequest" -}}
{{ if or (hasKey .annotations "cert-manager.io/cluster-issuer") (hasKey .annotations "cert-manager.io/issuer") (hasKey .annotations "kubernetes.io/tls-acme") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Render the annotations block for an HTTPRoute.
Automatically adds "mijnbureau.nl/tls-self-signed: true" when
cluster.tls.selfSigned is true, so the HSTS OPA policy skips those routes
without requiring a manual annotation.
Any additional annotations from cluster.gateway.annotations are merged in.
Usage: {{ include "common.httproute.annotations" . | nindent 2 }}
*/}}
{{- define "common.httproute.annotations" -}}
{{- $selfSigned := (((.Values.cluster | default dict).tls | default dict).selfSigned | default false) }}
{{- $extra := ((.Values.cluster | default dict).gateway | default dict).annotations | default dict }}
{{- if or $selfSigned $extra }}
annotations:
  {{- if $selfSigned }}
  mijnbureau.nl/tls-self-signed: "true"
  {{- end }}
  {{- with $extra }}
  {{- include "common.tplvalues.render" (dict "value" . "context" $) | nindent 2 }}
  {{- end }}
{{- end }}
{{- end -}}
