{{- define "toxindex.image" -}}
{{- $img := required (printf "global.images.%s is not defined" .name) (index .root.Values.global.images .name) -}}
{{- $repo := $img.repository | default (printf "%s/%s" .root.Values.global.registry .name) -}}
{{- $tag := required (printf "global.images.%s.tag is required" .name) $img.tag -}}
{{- $ref := printf "%s:%s" $repo (toString $tag) -}}
{{- if $img.digest -}}{{- $ref = printf "%s@%s" $ref (toString $img.digest) -}}{{- end -}}
{{- $ref -}}
{{- end -}}

{{- define "toxindex.toolImage" -}}
{{- $img := required (printf "global.images.%s is not defined" .name) (index .root.Values.global.images .name) -}}
{{- $repo := $img.repository | default (printf "%s/%s" .root.Values.global.toolsRegistry .name) -}}
{{- $tag := required (printf "global.images.%s.tag is required" .name) $img.tag -}}
{{- $ref := printf "%s:%s" $repo (toString $tag) -}}
{{- if $img.digest -}}{{- $ref = printf "%s@%s" $ref (toString $img.digest) -}}{{- end -}}
{{- $ref -}}
{{- end -}}

{{- define "toxindex.license.secret" -}}
{{- .root.Values.global.license.secret | default "tidx-license" -}}
{{- end -}}

{{- define "toxindex.license.registrySecret" -}}
{{- .root.Values.global.license.registrySecret | default "tools-pull" -}}
{{- end -}}

{{- define "toxindex.license.datasetSecret" -}}
{{- $prefix := .root.Values.global.license.datasetSecretPrefix | default "tidx-dataset" -}}
{{- printf "%s-%s" $prefix .name -}}
{{- end -}}

{{- define "toxindex.license.enabled" -}}
{{- $e := .root.Values.global.license | default dict -}}
{{- if or $e.key $e.remoteSecret -}}true{{- end -}}
{{- end -}}

{{- define "toxindex.remoteService" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ .name }}
  namespace: {{ .namespace }}
  annotations:
    tailscale.com/tailnet-fqdn: {{ required "tailnetFqdn is required for remote service" .fqdn }}
  labels:
    {{- .labels | nindent 4 }}
spec:
  type: ExternalName
  externalName: placeholder
{{- end -}}

{{- define "toxindex.upstream.crawlerSearch" -}}http://crawler-search{{- end -}}

{{- define "toxindex.upstream.crawlerResolver" -}}http://crawler-resolver{{- end -}}

{{- define "toxindex.upstream.kilnClickhouse" -}}http://kiln-clickhouse:8123{{- end -}}

{{- define "toxindex.upstream.kilnResolver" -}}http://kiln-resolver{{- end -}}

{{- define "toxindex.upstream.flowEngine" -}}http://flow-engine{{- end -}}

{{- define "toxindex.upstream.toxjobs" -}}http://toxjobs-manager:8080{{- end -}}

{{- define "toxindex.otelEndpoint" -}}
{{- $obs := .root.Values.global.observability | default dict -}}
{{- $obs.endpoint | default "http://otel-collector:4317" -}}
{{- end -}}

{{- define "toxindex.otelEnv" -}}
- name: OTEL_EXPORTER_OTLP_ENDPOINT
  value: {{ include "toxindex.otelEndpoint" (dict "root" .root) }}
- name: OTEL_SERVICE_NAME
  value: {{ .name }}
- name: OTEL_RESOURCE_ATTRIBUTES
  value: service.namespace=toxindex
{{- end -}}

{{- define "toxindex.podSecurityContext" -}}
runAsNonRoot: true
{{- with .uid }}
runAsUser: {{ . }}
{{- end }}
{{- with .gid }}
runAsGroup: {{ . }}
{{- end }}
seccompProfile:
  type: RuntimeDefault
{{- end -}}

{{- define "toxindex.containerSecurityContext" -}}
allowPrivilegeEscalation: false
capabilities:
  drop:
    - ALL
{{- end -}}

{{- define "toxindex.gpuScheduling" -}}
{{- $gpu := .Values.global.gpu | default dict -}}
{{- with $gpu.runtimeClassName }}
runtimeClassName: {{ . }}
{{- end }}
{{- with $gpu.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $gpu.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
