{{- define "sysrev.labels" -}}
{{- include "toxindex.labels" (dict "name" .name "release" .release "partOf" "sysrev" "component" .component) -}}
{{- end }}

{{- define "sysrev.selectorLabels" -}}
{{- include "toxindex.selectorLabels" (dict "name" .name) -}}
{{- end }}

{{- define "sysrev.migrateDbEnv" -}}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .root.Values.postgres.passwordSecret }}
      key: password
- name: DATABASE_URL
  value: "postgres://sysrev:$(POSTGRES_PASSWORD)@{{ .root.Values.postgres.host }}:5432/sysrev?sslmode=disable"
- name: APP_ROLE
  value: sysrev_app
- name: APP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .root.Values.postgres.appPasswordSecret }}
      key: password
{{- end }}

{{- define "sysrev.dbEnv" -}}
- name: APP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .root.Values.postgres.appPasswordSecret }}
      key: password
- name: SYSREV_DATABASE_URL
  value: "postgres://sysrev_app:$(APP_PASSWORD)@{{ .root.Values.postgres.host }}:5432/sysrev?sslmode=disable"
{{- end }}

{{- define "sysrev.blobDir" -}}/var/lib/sysrev{{- end }}
