{{- define "flow.labels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .release }}
app.kubernetes.io/part-of: flow
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{- define "flow.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
{{- end }}

{{- define "flow.migrateDbEnv" -}}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .root.Values.postgres.passwordSecret }}
      key: password
- name: DATABASE_URL
  value: "postgres://flow:$(POSTGRES_PASSWORD)@{{ .root.Values.postgres.host }}:5432/flow?sslmode=disable"
- name: APP_ROLE
  value: flow_app
- name: APP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .root.Values.postgres.appPasswordSecret }}
      key: password
{{- end }}

{{- define "flow.dbEnv" -}}
- name: APP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .root.Values.postgres.appPasswordSecret }}
      key: password
- name: DATABASE_URL
  value: "postgres://flow_app:$(APP_PASSWORD)@{{ .root.Values.postgres.host }}:5432/flow?sslmode=disable"
{{- end }}
