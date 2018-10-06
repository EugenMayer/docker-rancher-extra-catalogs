version: "2"

services:
  app:
    labels:
{{- if .Values.EXTRA_LABELS }}
{{.Values.EXTRA_LABELS | indent 6}}
{{- end}}
      {{- if eq .Values.MULTISERVICE "true"}}
      traefik.wohami80.port: 80
      traefik.wohami80.frontend.rule: 'Host whoami80.${TRAEFIK_BASE_DOMAIN}'
      traefik.wohami90.port: 90
      traefik.wohami90.frontend.rule: 'Host whoami90.${TRAEFIK_BASE_DOMAIN}'
      {{- else}}
      traefik.port: 80
      traefik.frontend.rule: ${TRAEFIK_FRONTEND_RULE}
      {{- end}}
      traefik.enable: true
      traefik.acme: ${TRAEFIK_FRONTEND_HTTPS_ENABLE}
      io.rancher.container.create_agent: 'true'
      io.rancher.container.agent.role: 'environment'
      io.rancher.container.pull_image: always

    {{- if eq .Values.MULTISERVICE "true"}}
    image: eugenmayer/whoami:multiple
    {{- else}}
    image: eugenmayer/whoami:single
    {{- end}}
