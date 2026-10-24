{{- define "flow.labels" -}}
{{- include "toxindex.labels" (dict "name" .name "release" .release "partOf" "flow" "component" .component) -}}
{{- end }}

{{- define "flow.selectorLabels" -}}
{{- include "toxindex.selectorLabels" (dict "name" .name) -}}
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
