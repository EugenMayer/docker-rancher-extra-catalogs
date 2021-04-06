version: "2"

services:
  app:
    labels:
{{- if .Values.EXTRA_LABELS }}
{{.Values.EXTRA_LABELS | indent 6}}
{{- end}}
      traefik.port: 9000
      traefik.frontend.rule: ${TRAEFIK_FRONTEND_RULE}
      traefik.enable: true
      traefik.acme: ${TRAEFIK_FRONTEND_HTTPS_ENABLE}
      io.rancher.container.create_agent: 'true'
      io.rancher.container.agent.role: 'environment'
      io.rancher.container.pull_image: always
    image: sonarqube:lts
