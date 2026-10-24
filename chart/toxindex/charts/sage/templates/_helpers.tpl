{{- define "sage.labels" -}}
{{- include "toxindex.labels" (dict "name" .name "release" .release "partOf" "sage" "component" .component) -}}
{{- end }}

{{- define "sage.selectorLabels" -}}
{{- include "toxindex.selectorLabels" (dict "name" .name) -}}
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

{{- define "sage.blobDir" -}}/var/lib/sage{{- end }}

{{- define "sage.blobsOnDisk" -}}
{{- if not .Values.fileStore.bucket -}}true{{- end -}}
{{- end -}}

{{- define "sage.rolloutStrategy" -}}
{{- if include "sage.blobsOnDisk" . -}}
type: Recreate
{{- else -}}
type: RollingUpdate
rollingUpdate:
  maxUnavailable: 0
  maxSurge: 1
{{- end -}}
{{- end -}}
