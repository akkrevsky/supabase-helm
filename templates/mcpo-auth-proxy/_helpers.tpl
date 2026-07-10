{{/* auth-proxy name */}}
{{- define "supabase.mcpo-auth-proxy.name" -}}
{{- default (print .Chart.Name "-mcpo-auth-proxy") .Values.mcpo.authProxy.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* auth-proxy fully qualified app name */}}
{{- define "supabase.mcpo-auth-proxy.fullname" -}}
{{- if .Values.mcpo.authProxy.fullnameOverride }}
{{- .Values.mcpo.authProxy.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default (print .Chart.Name "-mcpo-auth-proxy") .Values.mcpo.authProxy.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/* auth-proxy selector labels */}}
{{- define "supabase.mcpo-auth-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "supabase.mcpo-auth-proxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
