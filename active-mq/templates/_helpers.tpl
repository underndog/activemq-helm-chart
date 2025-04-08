{{/*
Expand the name of the chart.
*/}}
{{- define "active-mq.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "active-mq.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "active-mq.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "active-mq.labels" -}}
helm.sh/chart: {{ include "active-mq.chart" . }}
{{ include "active-mq.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "active-mq.selectorLabels" -}}
app.kubernetes.io/name: {{ include "active-mq.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "active-mq.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "active-mq.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
JMX username with default
*/}}
{{- define "active-mq.jmxUsername" -}}
{{- .Values.monitoring.jmx.username | default (default "admin" .Values.authentication.defaultUsername) -}}
{{- end -}}

{{/*
JMX password with default or random generation
*/}}
{{- define "active-mq.jmxPassword" -}}
{{- .Values.monitoring.jmx.password | default (coalesce .Values.authentication.defaultPassword (randAlphaNum 16)) -}}
{{- end -}}
