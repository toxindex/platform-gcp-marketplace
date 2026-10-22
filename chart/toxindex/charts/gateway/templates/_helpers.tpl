{{- define "gateway.labels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .release }}
app.kubernetes.io/part-of: gateway
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{- define "gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
{{- end }}
