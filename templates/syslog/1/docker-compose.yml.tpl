version: "2"

services:
  app:
    labels:
{{- if .Values.EXTRA_LABELS }}
{{.Values.EXTRA_LABELS | indent 6}}
{{- end}}
      io.rancher.container.create_agent: 'true'
      io.rancher.container.agent.role: 'environment'
      io.rancher.container.pull_image: always
    image: balabit/syslog-ng
    ports:
    {{- if ne .Values.SYSLOG_HOST_PORT ""}}
    - ${SYSLOG_HOST_PORT}:514/udp
    {{- end}}