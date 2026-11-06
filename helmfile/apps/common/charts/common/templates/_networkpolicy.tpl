{{- /* DNS egress shared by application and datastore network policies. */ -}}
{{- define "common.networkPolicy.dnsEgress" -}}
{{- $dns := get (.context.Values.global | default dict) "dns" | default dict -}}
{{- $external := get $dns "external" | default dict -}}
{{- $internal := get $dns "internal" | default dict -}}
{{- $protocols := get . "protocols" | default (list "UDP" "TCP") -}}
# Allow external DNS resolution
- ports:
{{- range $protocols }}
    - port: {{ $external.port | default 53 }}
      protocol: {{ . }}
{{- end }}
{{- if or $internal.port $internal.namespace }}
# Allow internal DNS resolution
- ports:
{{- range $protocols }}
    - port: {{ $internal.port | default 53 }}
      protocol: {{ . }}
{{- end }}
{{- with $internal.namespace }}
  to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: {{ . | quote }}
{{- end }}
{{- end }}
{{- end -}}
