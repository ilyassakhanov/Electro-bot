{{- define "my-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "my-app.fullname" -}}
{{- printf "%s-%s" (include "my-app.name" .) .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "my-app.selenium.fullname" -}}
{{- printf "%s-selenium" (include "my-app.fullname" .) -}}
{{- end -}}