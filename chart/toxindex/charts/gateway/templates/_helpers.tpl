{{- define "gateway.labels" -}}
{{- include "toxindex.labels" (dict "name" .name "release" .release "partOf" "gateway" "component" .component) -}}
{{- end }}

{{- define "gateway.selectorLabels" -}}
{{- include "toxindex.selectorLabels" (dict "name" .name) -}}
{{- end }}
