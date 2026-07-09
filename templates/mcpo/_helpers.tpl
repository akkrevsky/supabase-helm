{{/*
mcpo (MCP→HTTP bridge) name
*/}}
{{- define "supabase.mcpo.name" -}}
{{- default (print .Chart.Name "-mcpo") .Values.mcpo.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
mcpo fully qualified app name
*/}}
{{- define "supabase.mcpo.fullname" -}}
{{- if .Values.mcpo.fullnameOverride }}
{{- .Values.mcpo.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default (print .Chart.Name "-mcpo") .Values.mcpo.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
mcpo selector labels
*/}}
{{- define "supabase.mcpo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "supabase.mcpo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
