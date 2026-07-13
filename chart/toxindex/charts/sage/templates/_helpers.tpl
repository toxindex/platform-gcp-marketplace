{{- define "sage.labels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .release }}
app.kubernetes.io/part-of: sage
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{- define "sage.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
{{- end }}

{{- define "sage.fileStoreEnv" -}}
{{- with .root.Values.fileStore.bucket }}
- name: GCS_BUCKET
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- define "sage.migrateDbEnv" -}}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .root.Values.postgres.passwordSecret }}
      key: password
- name: DATABASE_URL
  value: "postgres://sage:$(POSTGRES_PASSWORD)@{{ .root.Values.postgres.host }}:5432/sage?sslmode=disable"
- name: APP_ROLE
  value: sage_app
- name: APP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .root.Values.postgres.appPasswordSecret }}
      key: password
{{- end }}

{{- define "sage.dbEnv" -}}
- name: APP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .root.Values.postgres.appPasswordSecret }}
      key: password
- name: DATABASE_URL
  value: "postgres://sage_app:$(APP_PASSWORD)@{{ .root.Values.postgres.host }}:5432/sage?sslmode=disable"
{{- end }}
