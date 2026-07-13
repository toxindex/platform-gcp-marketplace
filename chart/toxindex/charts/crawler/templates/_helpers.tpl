{{- define "crawler.labels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .release }}
app.kubernetes.io/part-of: crawler
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{- define "crawler.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
{{- end }}

{{- define "crawler.dbEnv" -}}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .root.Values.postgres.passwordSecret }}
      key: password
- name: {{ .var }}
  value: "postgres://crawler:$(POSTGRES_PASSWORD)@{{ .root.Values.postgres.host }}:5432/crawler?sslmode=disable"
{{- end }}
