version: "2"

services:
  nexus:
    # https://hub.docker.com/r/sonatype/nexus3/tags
    image: sonatype/nexus3:3.34.1
    volumes:
      - ${DATA}:/nexus-data
      - nexusplugins:/opt/sonatype/nexus/deploy
    labels:
      traefik.enable: true
      traefik.acme: ${TRAEFIK_FRONTEND_HTTPS_ENABLE}
  {{- if .Values.TRAEFIK_FRONTEND_RULE }}
      traefik.port: 8081
      traefik.frontend.rule: ${TRAEFIK_FRONTEND_RULE}
  {{- end}}
      io.rancher.container.create_agent: 'true'
      io.rancher.container.agent.role: 'environment'
{{- if .Values.EXTRA_LABELS }}
{{.Values.EXTRA_LABELS | indent 6}}
{{- end}}
  {{- if .Values.EXPOSE_PORT }}
  ports:
    {{.Values.EXPOSE_PORT}}:8081
  {{- end}}
volumes:
  nexusplugins:
    driver: local
