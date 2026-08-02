{{- define "rentacar-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "rentacar-api.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "rentacar-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "rentacar-api.labels" -}}
helm.sh/chart: {{ include "rentacar-api.chart" . }}
app.kubernetes.io/name: {{ include "rentacar-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "rentacar-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rentacar-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "rentacar-api.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "rentacar-api.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "rentacar-api.databaseSecretName" -}}
{{- if .Values.externalSecrets.enabled -}}
{{- required "externalSecrets.targetSecretName is required when externalSecrets.enabled=true" .Values.externalSecrets.targetSecretName -}}
{{- else -}}
{{- required "existingSecret.name is required when externalSecrets.enabled=false" .Values.existingSecret.name -}}
{{- end -}}
{{- end -}}

{{- define "rentacar-api.image" -}}
{{- $repo := required "image.repository is required. Use an immutable ECR repository URL." .Values.image.repository -}}
{{- $tag := required "image.tag is required. Use an immutable commit SHA tag, never latest." .Values.image.tag -}}
{{- if eq $tag "latest" -}}
{{- fail "image.tag must not be latest. Use an immutable commit SHA tag." -}}
{{- end -}}
{{- printf "%s:%s" $repo $tag -}}
{{- end -}}
