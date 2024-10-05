{{/*
Expand the name of the chart.
*/}}
{{- define "splunk-synthetics-runner.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "splunk-synthetics-runner.fullname" -}}
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
{{- define "splunk-synthetics-runner.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "splunk-synthetics-runner.labels" -}}
helm.sh/chart: {{ include "splunk-synthetics-runner.chart" . }}
{{ include "splunk-synthetics-runner.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "splunk-synthetics-runner.selectorLabels" -}}
app.kubernetes.io/name: {{ include "splunk-synthetics-runner.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Values.commonLabels }}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/*
Pod labels
*/}}
{{- define "splunk-synthetics-runner.podLabels" -}}
{{- $commonLabels := include "splunk-synthetics-runner.labels" . | fromYaml -}}
{{- $podLabels := mustMerge .Values.podLabels $commonLabels -}}
{{ toYaml $podLabels }}
{{- end -}}

{{/*
Define name for the runner token secret
*/}}
{{- define "splunk-synthetics-runner.secretName" -}}
{{- default (include "splunk-synthetics-runner.fullname" .) .Values.synthetics.secret.name }}
{{- end -}}

{{/*
Define name for the runner service account
*/}}
{{- define "splunk-synthetics-runner.serviceAccountName" -}}
{{- default (include "splunk-synthetics-runner.fullname" .) .Values.serviceAccount.name }}
{{- end -}}

{{/*
Render security context
*/}}
{{- define "splunk-synthetics-runner.containerSecurityContext" -}}
{{- $secContext := .Values.containerSecurityContext -}}
{{- $netadminCap := dict "allowPrivilegeEscalation" true "capabilities" (dict "add" (list "NET_ADMIN")) -}}
{{- if and .Values.synthetics.enableNetworkShaping (not $secContext) -}}
  {{/* if no custom security context provided but n/w shaping is enabled, add CAP_NET_ADMIN */}}
  {{- $secContext = $netadminCap }}
{{- else if and $secContext .Values.synthetics.enableNetworkShaping -}}
{{/* if custom securityContext exists and net shaping is enabled, we try to merge the two for final context */}}
    {{- if (((.Values.containerSecurityContext).capabilities).add) -}}
    {{/* custom secContext has capabilities.add, we append NET_ADMIN */}}
    {{- $_ := set $secContext.capabilities "add" (mustAppend .Values.containerSecurityContext.capabilities.add "NET_ADMIN" | uniq) -}}
    {{- else -}}
    {{- $secContext = mustMerge $netadminCap .Values.containerSecurityContext -}}
    {{- end -}}
{{- end -}}
{{ toYaml $secContext }}
{{- end -}}

{{/*
Render names compliant with DNS label standard as defined in RFC 1123
*/}}
{{- define "cleanupNames" -}}
  {{- $name := regexReplaceAll "[^A-Za-z0-9\\-]" . "-" | lower -}}
  {{- $name = regexReplaceAll "^-+|-+$" $name "" | trunc 63 | trimSuffix "-" -}}
  {{- $name -}}
{{- end -}}


{{/*
Render pod annotations. TEST
Checksums are calculated for secret and additionalCaCerts if they exist. This
checksum is further used to trigger a rolling update when the secret/configmap
changes. The checksum is stored in the pod annotation `checksum/config`.
*/}}
{{- define "splunk-synthetics-runner.podAnnotations" -}}
{{- $checksums := list -}}
{{- if and .Values.synthetics.secret.create .Values.synthetics.secret.runnerToken -}}
{{- $checksums = append $checksums (include (print .Template.BasePath "/secret.yaml") . | sha256sum) }}
{{- end -}}
{{- if .Values.synthetics.additionalCaCerts -}}
{{- $checksums = append $checksums (include (print .Template.BasePath "/configmap-ca.yaml" ) . | sha256sum) }}
{{- end -}}
{{- if or $checksums .Values.podAnnotations -}}
annotations:
{{- if $checksums  }}
  checksum/config: {{ (join "" $checksums) | sha256sum }}
{{- end -}}
{{- if .Values.podAnnotations -}}
{{- toYaml .Values.podAnnotations | nindent 2 }}
{{- end -}}
{{- end -}}
{{- end -}}
