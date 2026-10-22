{{- define "kiln.labels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .release }}
app.kubernetes.io/part-of: kiln
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{- define "kiln.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
{{- end }}
