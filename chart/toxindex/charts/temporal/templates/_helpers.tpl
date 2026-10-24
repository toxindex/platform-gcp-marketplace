{{- define "temporal.labels" -}}
{{- include "toxindex.labels" (dict "name" .name "release" .release "partOf" "temporal" "component" .component) -}}
{{- end }}

{{- define "temporal.selectorLabels" -}}
{{- include "toxindex.selectorLabels" (dict "name" .name) -}}
{{- end }}

{{- define "temporal.dnsEgress" -}}
- to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
  ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
{{- end }}

{{- define "temporal.peerTraffic" -}}
- {{ .direction }}:
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: temporal-server
  ports:
    - protocol: TCP
      port: 7233
      endPort: 7239
    - protocol: TCP
      port: 6933
      endPort: 6939
    - protocol: UDP
      port: 6933
      endPort: 6939
{{- end }}
