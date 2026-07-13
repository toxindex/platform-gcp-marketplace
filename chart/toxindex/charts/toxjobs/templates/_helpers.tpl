{{- define "toxjobs.labels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .release }}
app.kubernetes.io/part-of: toxjobs
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{- define "toxjobs.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
{{- end }}
