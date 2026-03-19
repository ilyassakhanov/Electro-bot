{{- define "my-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "my-app.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "my-app.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "my-app.selenium.fullname" -}}
{{- printf "%s-selenium" (include "my-app.fullname" .) -}}
{{- end -}}