{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "skylite.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "skylite.fullname" -}}
{{- if contains .Chart.Name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "skylite.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "skylite.labels" -}}
helm.sh/chart: {{ include "skylite.chart" . }}
{{ include "skylite.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: {{ include "skylite.uname" . }}
{{- with .Values.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "skylite.selectorLabels" -}}
app.kubernetes.io/name: {{ include "skylite.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "skylite.uname" -}}
{{- if empty .Values.fullnameOverride -}}
{{- if empty .Values.nameOverride -}}
{{ .Values.clusterName }}-{{ .Values.nodeGroup }}
{{- else -}}
{{ .Values.nameOverride }}-{{ .Values.nodeGroup }}
{{- end -}}
{{- else -}}
{{ .Values.fullnameOverride }}
{{- end -}}
{{- end -}}

{{- define "skylite.managerService" -}}
{{- if empty .Values.managerService -}}
{{- if empty .Values.fullnameOverride -}}
{{- if empty .Values.nameOverride -}}
{{ .Values.clusterName }}-manager
{{- else -}}
{{ .Values.nameOverride }}-manager
{{- end -}}
{{- else -}}
{{ .Values.fullnameOverride }}
{{- end -}}
{{- else -}}
{{ .Values.managerService }}
{{- end -}}
{{- end -}}

{{- define "skylite.serviceName" -}}
{{- if eq .Values.nodeGroup "manager" }}
{{- include "skylite.managerService" . }}
{{- else }}
{{- include "skylite.uname" . }}
{{- end }}
{{- end -}}

{{- define "skylite.endpoints" -}}
{{- $replicas := int (toString (.Values.replicaCount)) }}
{{- $uname := (include "skylite.uname" .) }}
  {{- range $i, $e := untilStep 0 $replicas 1 -}}
{{ $uname }}-{{ $i }},
  {{- end -}}
{{- end -}}

{{- define "skylite.majorVersion" -}}
{{- if .Values.majorVersion }}
  {{- .Values.majorVersion }}
{{- else }}
  {{- $version := semver (coalesce .Values.image.tag .Chart.AppVersion "1") }}
  {{- $version.Major }}
{{- end }}
{{- end }}

{{- define "skylite.dockerRegistry" -}}
{{- if eq .Values.global.dockerRegistry "" -}}
  {{- .Values.global.dockerRegistry -}}
{{- else -}}
  {{- .Values.global.dockerRegistry | trimSuffix "/" | printf "%s/" -}}
{{- end -}}
{{- end -}}

{{- define "skylite.roles" -}}
{{- range $.Values.roles -}}
{{ . }},
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "skylite.ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "skylite.ingress.isStable" -}}
  {{- eq (include "skylite.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}
{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "skylite.ingress.supportsIngressClassName" -}}
  {{- or (eq (include "skylite.ingress.isStable" .) "true") (and (eq (include "skylite.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) -}}
{{- end -}}
