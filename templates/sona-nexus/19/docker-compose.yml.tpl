nexus:
  image: sonatype/nexus3:3.13.0
  volumes:
    - ${DATA}:/nexus-data
  labels:
{{- if .Values.TRAEFIK_FRONTEND_RULE }}
    traefik.enable: true
    traefik.port: 8081
    traefik.frontend.rule: ${TRAEFIK_FRONTEND_RULE}
{{- end}}
    traefik.acme: ${TRAEFIK_FRONTEND_HTTPS_ENABLE}
    io.rancher.container.create_agent: 'true'
    io.rancher.container.agent.role: 'environment'
{{- if .Values.EXTRA_LABELS }}
{{.Values.EXTRA_LABELS | indent 4}}
{{- end}}