{{/*
This template generates a random password and ensures it persists across updates/edits to the chart
*/}}
{{- define "tc.v1.common.dependencies.mongodb.secret" -}}

{{- if .Values.mongodb.enabled -}}
  {{/* Initialize variables */}}
  {{- $basename := include "tc.v1.common.lib.chart.names.fullname" $ -}}
  {{- $fetchname := printf "%s-mongodbcreds" $basename -}}
  {{- $dbprevious := lookup "v1" "Secret" .Release.Namespace $fetchname -}}
  {{- $dbpreviousold := lookup "v1" "Secret" .Release.Namespace "mongodbcreds" -}}
  {{- $dbPass := randAlphaNum 50 -}}
  {{- $rootPass := randAlphaNum 50 -}}

  {{/* If there are previous secrets, fetch values and decrypt them */}}
  {{- if $dbprevious -}}
    {{- $dbPass = (index $dbprevious.data "mongodb-password") | b64dec -}}
    {{- $rootPass = (index $dbprevious.data "mongodb-root-password") | b64dec -}}
  {{- else if $dbpreviousold -}}
    {{- $dbPass = (index $dbpreviousold.data "mongodb-password") | b64dec -}}
    {{- $rootPass = (index $dbpreviousold.data "mongodb-root-password") | b64dec -}}
  {{- end -}}

  {{/* Prepare data */}}
  {{- $dbhost := printf "%v-%v" .Release.Name "mongodb" -}}
  {{- $portHost := printf "%v:27017" $dbhost -}}
  {{- $jdbc := printf "jdbc:mongodb://%v/%v" $portHost .Values.mongodb.mongodbDatabase -}}
  {{- $url := printf "mongodb://%v:%v@%v/%v" .Values.mongodb.mongodbUsername $dbPass $portHost .Values.mongodb.mongodbDatabase -}}
  {{- $urlssl := printf "%v?ssl=true" $url -}}
  {{- $urltls := printf "%v?tls=true" $url -}}

  {{/* Append some values to mongodb.creds, so apps using the dep, can use them */}}
  {{- $_ := set .Values.mongodb.creds "mongodbPassword" ($dbPass | quote) -}}
  {{- $_ := set .Values.mongodb.creds "mongodbRootPassword" ($rootPass | quote) -}}
  {{- $_ := set .Values.mongodb.creds "plain" ($dbhost | quote) -}}
  {{- $_ := set .Values.mongodb.creds "plainhost" ($dbhost | quote) -}}
  {{- $_ := set .Values.mongodb.creds "plainport" ($portHost | quote) -}}
  {{- $_ := set .Values.mongodb.creds "plainporthost" ($portHost | quote) -}}
  {{- $_ := set .Values.mongodb.creds "complete" ($url | quote) -}}
  {{- $_ := set .Values.mongodb.creds "urlssl" ($urlssl | quote) -}}
  {{- $_ := set .Values.mongodb.creds "urltls" ($urltls | quote) -}}
  {{- $_ := set .Values.mongodb.creds "jdbc" ($jdbc | quote) -}}

{{/* Create the secret (Comment also plays a role on correct formatting) */}}
enabled: true
expandObjectName: false
data:
  mongodb-password: {{ $dbPass }}
  mongodb-root-password: {{ $rootPass }}
  url: {{ $url }}
  urlssl: {{ $urlssl }}
  urltls: {{ $urltls }}
  jdbc: {{ $jdbc }}
  plainhost: {{ $dbhost }}
  plainporthost: {{ $portHost }}
  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.dependencies.mongodb.injector" -}}
  {{- $secret := include "tc.v1.common.dependencies.mongodb.secret" . | fromYaml -}}
  {{- if $secret -}}
    {{- $_ := set .Values.secret (printf "%s-%s" .Release.Name "mongodbcreds") $secret -}}
  {{- end -}}
{{- end -}}
