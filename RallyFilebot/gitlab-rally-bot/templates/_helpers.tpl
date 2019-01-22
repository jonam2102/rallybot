{{/* vim: set filetype=mustache: */}}
{{/*
 Expand the name of the chart . 
*/}}
{{- define "gitlab-rally-bot.name" - }}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name. 
We truncate at 63 chars because some kubernetes name fields are limited to this ( by DNS naming) 
*/}}
{{- define "gitlab-rally-bot.fullname"  -}}
{{- $name := default .Chart.Name .Values.nameOverride - }} 
{{ -printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" - }}
{{ - end - }} 


