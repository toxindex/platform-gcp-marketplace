{{- define "kiln.labels" -}}
{{- include "toxindex.labels" (dict "name" .name "release" .release "partOf" "kiln" "component" .component) -}}
{{- end }}

{{- define "kiln.selectorLabels" -}}
{{- include "toxindex.selectorLabels" (dict "name" .name) -}}
{{- end }}

{{- define "kiln.quantityToBytes" -}}
{{- $q := . | toString | trim -}}
{{- if hasSuffix "Gi" $q -}}{{- mulf (trimSuffix "Gi" $q) 1073741824 | int64 -}}
{{- else if hasSuffix "Mi" $q -}}{{- mulf (trimSuffix "Mi" $q) 1048576 | int64 -}}
{{- else if hasSuffix "Ki" $q -}}{{- mulf (trimSuffix "Ki" $q) 1024 | int64 -}}
{{- else if hasSuffix "G" $q -}}{{- mulf (trimSuffix "G" $q) 1000000000 | int64 -}}
{{- else if hasSuffix "M" $q -}}{{- mulf (trimSuffix "M" $q) 1000000 | int64 -}}
{{- else if hasSuffix "K" $q -}}{{- mulf (trimSuffix "K" $q) 1000 | int64 -}}
{{- else if regexMatch "^[0-9]+$" $q -}}{{- $q | int64 -}}
{{- else -}}{{- fail (printf "kiln clickhouse memory quantity %q not understood; use Ki/Mi/Gi or plain bytes" $q) -}}
{{- end -}}
{{- end -}}
