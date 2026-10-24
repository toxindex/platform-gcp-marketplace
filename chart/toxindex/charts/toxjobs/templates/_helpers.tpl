{{- define "toxjobs.labels" -}}
{{- include "toxindex.labels" (dict "name" .name "release" .release "partOf" "toxjobs" "component" .component) -}}
{{- end }}

{{- define "toxjobs.selectorLabels" -}}
{{- include "toxindex.selectorLabels" (dict "name" .name) -}}
{{- end }}
