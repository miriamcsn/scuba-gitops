{{/* Labels padrão aplicados a todos os objetos */}}
{{- define "scuba.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}

{{/* Labels de seleção: usados pelos Services para achar os Pods */}}
{{- define "scuba.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Imagem completa de um componente. Uso: include "scuba.image" (dict "root" . "image" .Values.backend.image "name" "backend") */}}
{{- define "scuba.image" -}}
{{- $registry := required "image.registry é obrigatório (defina em envs/<ambiente>/values.yaml)" .root.Values.image.registry -}}
{{- $tag := required (printf "%s.image.tag é obrigatório (o CI grava em envs/<ambiente>/values.yaml)" .name) .image.tag -}}
{{- printf "%s/%s:%s" $registry .image.repository $tag -}}
{{- end }}

{{/* imagePullSecrets, quando definidos */}}
{{- define "scuba.imagePullSecrets" -}}
{{- with .Values.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
