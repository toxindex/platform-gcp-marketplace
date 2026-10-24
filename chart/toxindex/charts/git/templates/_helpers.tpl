{{- define "git.labels" -}}
{{- include "toxindex.labels" (dict "name" .name "release" .release "partOf" "git" "component" .component) -}}
{{- end }}

{{- define "git.selectorLabels" -}}
{{- include "toxindex.selectorLabels" (dict "name" .name) -}}
{{- end }}

{{- define "git.migrateDbEnv" -}}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .root.Values.postgres.passwordSecret }}
      key: password
- name: DATABASE_URL
  value: "postgres://git:$(POSTGRES_PASSWORD)@{{ .root.Values.postgres.host }}:5432/git?sslmode=disable"
- name: APP_ROLE
  value: git_app
- name: APP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .root.Values.postgres.appPasswordSecret }}
      key: password
{{- end }}

{{- define "git.dbEnv" -}}
- name: APP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .root.Values.postgres.appPasswordSecret }}
      key: password
- name: DATABASE_URL
  value: "postgres://git_app:$(APP_PASSWORD)@{{ .root.Values.postgres.host }}:5432/git?sslmode=disable"
{{- end }}

{{- define "git.blobDir" -}}/var/lib/git{{- end }}

{{- define "git.blobsOnDisk" -}}
{{- if not .Values.global.repoStore.bucket -}}true{{- end -}}
{{- end -}}
