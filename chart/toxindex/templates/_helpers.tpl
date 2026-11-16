{{- define "toxindex.labels" -}}
app.kubernetes.io/name: {{ required "toxindex.labels needs a name" .name }}
app.kubernetes.io/instance: {{ required "toxindex.labels needs a release" .release }}
app.kubernetes.io/part-of: {{ required "toxindex.labels needs a partOf" .partOf }}
app.kubernetes.io/component: {{ required "toxindex.labels needs a component" .component }}
{{- end -}}

{{- define "toxindex.selectorLabels" -}}
app.kubernetes.io/name: {{ required "toxindex.selectorLabels needs a name" .name }}
{{- end -}}

{{- define "toxindex.image" -}}
{{- $img := required (printf "global.images.%s is not defined" .name) (index .root.Values.global.images .name) -}}
{{- $repo := $img.repository | default (printf "%s/%s" .root.Values.global.registry .name) -}}
{{- $tag := required (printf "global.images.%s.tag is required" .name) $img.tag -}}
{{- $digest := required (printf "global.images.%s.digest is required" .name) $img.digest -}}
{{- printf "%s:%s@%s" $repo (toString $tag) (toString $digest) -}}
{{- end -}}

{{- define "toxindex.imageTag" -}}
{{- $img := required (printf "global.images.%s is not defined" .name) (index .root.Values.global.images .name) -}}
{{- required (printf "global.images.%s.tag is required" .name) $img.tag | toString -}}
{{- end -}}

{{- define "toxindex.toolImage" -}}
{{- $img := required (printf "global.images.%s is not defined" .name) (index .root.Values.global.images .name) -}}
{{- $repo := $img.repository | default (printf "%s/%s" .root.Values.global.toolsRegistry .name) -}}
{{- $tag := required (printf "global.images.%s.tag is required" .name) $img.tag -}}
{{- $digest := required (printf "global.images.%s.digest is required" .name) $img.digest -}}
{{- printf "%s:%s@%s" $repo (toString $tag) (toString $digest) -}}
{{- end -}}

{{- define "toxindex.license.secret" -}}
{{- .root.Values.global.license.secret | default "tidx-license" -}}
{{- end -}}

{{- define "toxindex.license.registrySecret" -}}
{{- .root.Values.global.license.registrySecret | default "tools-pull" -}}
{{- end -}}

{{- define "toxindex.license.registryHost" -}}
{{- (splitList "/" .root.Values.global.toolsRegistry) | first -}}
{{- end -}}

{{- define "toxindex.platformPullSecret" -}}
platform-pull
{{- end -}}

{{- define "toxindex.platformPullsFromLicense" -}}
{{- if eq ((splitList "/" .Values.global.registry) | first) (include "toxindex.license.registryHost" (dict "root" .)) -}}
true
{{- end -}}
{{- end -}}

{{- define "toxindex.platformImagePullSecrets" -}}
{{- if include "toxindex.platformPullsFromLicense" . }}
imagePullSecrets:
  - name: {{ include "toxindex.platformPullSecret" . }}
{{- end }}
{{- end -}}

{{- define "toxindex.license.grantsSecret" -}}
{{- .root.Values.global.license.grantsSecret | default "tidx-grants" -}}
{{- end -}}

{{- define "toxindex.license.entitlementsSecret" -}}
{{- .root.Values.global.license.entitlementsSecret | default "tidx-entitlements" -}}
{{- end -}}

{{- define "toxindex.license.installSecret" -}}
{{- $e := .root.Values.global.license | default dict -}}
{{- if kindIs "invalid" $e.installSecret -}}tidx-install{{- else -}}{{- $e.installSecret -}}{{- end -}}
{{- end -}}

{{- define "toxindex.entitlementsUnlicensedConfigMap" -}}
{{- printf "%s-unlicensed" (include "toxindex.license.entitlementsSecret" (dict "root" .root)) -}}
{{- end -}}

{{- define "toxindex.entitlementsEnv" -}}
- name: ENTITLEMENTS_FILE
  value: /etc/toxindex/entitlements/plans
{{- end -}}

{{- define "toxindex.entitlementsVolumeMount" -}}
- name: entitlements
  mountPath: /etc/toxindex/entitlements
  readOnly: true
{{- end -}}

{{- define "toxindex.entitlementsVolume" -}}
- name: entitlements
{{- if include "toxindex.license.enabled" (dict "root" .root) }}
  secret:
    secretName: {{ include "toxindex.license.entitlementsSecret" (dict "root" .root) }}
{{- else }}
  configMap:
    name: {{ include "toxindex.entitlementsUnlicensedConfigMap" (dict "root" .root) }}
{{- end }}
{{- end -}}

{{- define "toxindex.license.datasetSecret" -}}
{{- $prefix := .root.Values.global.license.datasetSecretPrefix | default "tidx-dataset" -}}
{{- printf "%s-%s" $prefix .name -}}
{{- end -}}

{{- define "toxindex.license.enabled" -}}
{{- $e := .root.Values.global.license | default dict -}}
{{- if or $e.key $e.remoteSecret -}}true{{- end -}}
{{- end -}}

{{- define "toxindex.blobStoreEnv" -}}
{{- if .bucket -}}
- name: BLOB_BUCKET
  value: {{ .bucket | quote }}
{{- with .signerServiceAccount }}
- name: BLOB_SIGNER_SERVICE_ACCOUNT
  value: {{ . | quote }}
{{- end }}
{{- else if .dir -}}
- name: BLOB_DIR
  value: {{ .dir | quote }}
{{- end -}}
{{- end -}}

{{- define "toxindex.upstream.kilnClickhouse" -}}http://kiln-clickhouse:8123{{- end -}}

{{- define "toxindex.upstream.kilnFts" -}}http://kiln-fts{{- end -}}

{{- define "toxindex.upstream.kilnQuery" -}}http://kiln-query{{- end -}}

{{- define "toxindex.upstream.kilnResolver" -}}http://kiln-resolver{{- end -}}

{{- define "toxindex.upstream.kilnSparql" -}}http://kiln-sparql{{- end -}}

{{- define "toxindex.upstream.flowEngine" -}}http://flow-engine{{- end -}}

{{- define "toxindex.upstream.flowMetering" -}}http://flow-engine:8081{{- end -}}

{{- define "toxindex.upstream.temporal" -}}temporal-server:7233{{- end -}}

{{- define "toxindex.upstream.gitEngine" -}}http://git-engine{{- end -}}

{{- define "toxindex.upstream.toxjobs" -}}http://toxjobs-manager:8080{{- end -}}

{{- define "toxindex.upstream.sysrevApi" -}}http://sysrev-api{{- end -}}

{{- define "toxindex.upstream.sysrevMetering" -}}http://sysrev-api:8081{{- end -}}

{{- define "toxindex.otelEndpoint" -}}
{{- $obs := .root.Values.global.observability | default dict -}}
{{- $obs.endpoint | default "http://otel-collector:4317" -}}
{{- end -}}

{{- define "toxindex.auditExporters" -}}
{{- $obs := .root.Values.observability -}}
{{- $names := required "observability.pipelines.audit must name the exporters audit events leave through" $obs.pipelines.audit -}}
{{- range $names -}}
{{- if not (hasKey $obs.exporters .) -}}
{{- fail (printf "observability.pipelines.audit names %q, which observability.exporters does not define" .) -}}
{{- end -}}
{{- end -}}
{{- join ", " $names -}}
{{- end -}}

{{- define "toxindex.otelEnv" -}}
- name: OTEL_EXPORTER_OTLP_ENDPOINT
  value: {{ include "toxindex.otelEndpoint" (dict "root" .root) }}
- name: OTEL_SERVICE_NAME
  value: {{ .name }}
- name: OTEL_RESOURCE_ATTRIBUTES
  value: service.namespace=toxindex,service.version={{ include "toxindex.imageTag" (dict "root" .root "name" .name) }}
{{- end -}}

{{- define "toxindex.operator" -}}
{{- .root.Values.global.operator | default "self" -}}
{{- end -}}

{{- define "toxindex.operatorEnv" -}}
- name: TOXINDEX_OPERATOR
  value: {{ include "toxindex.operator" (dict "root" .root) | quote }}
{{- end -}}

{{- define "toxindex.namespaceEnv" -}}
- name: NAMESPACE
  value: {{ .root.Values.global.namespace | default .root.Release.Namespace | quote }}
{{- end -}}

{{- define "toxindex.proxyAuthSecretName" -}}
{{- $g := .Values.global -}}
{{- if $g.proxyAuthRemoteSecret -}}
{{- $version := required "global.proxyAuthRemoteVersion is required with global.proxyAuthRemoteSecret, so a rotation rolls every pod that reads it" $g.proxyAuthRemoteVersion -}}
{{- printf "%s-%s" $g.proxyAuthSecret (printf "%s@%v" $g.proxyAuthRemoteSecret $version | sha256sum | trunc 8) -}}
{{- else -}}
{{- $g.proxyAuthSecret -}}
{{- end -}}
{{- end -}}

{{- define "toxindex.gcpMetadataEgress" -}}
- to:
    - ipBlock:
        cidr: 169.254.169.254/32
    - ipBlock:
        cidr: 169.254.169.252/32
  ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 988
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

{{- define "toxindex.preStopDrain" -}}
lifecycle:
  preStop:
    sleep:
      seconds: 5
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
