version: "2"

services:
  app:
    # https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes
    image: docker.bintray.io/jfrog/artifactory-cpp-ce
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
    environment:
      DB_TYPE: postgresql
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      DB_URL: jdbc:postgresql://db:5432/${DB_NAME}
    volumes:
    {{- if .Values.DATA_VOLUME_NAME}}
    - {{.Values.DATA_VOLUME_NAME}}:/var/opt/jfrog/artifactory
    {{- else}}
    - jfrogdata:/var/opt/jfrog/artifactory
    {{- end }}
  db:
    image: postgres:10
    {{- if .Values.HOST_AFFINITY_LABEL}}
    labels:
      io.rancher.scheduler.affinity: {{.Values.HOST_AFFINITY_LABEL}}
    {{- end }}
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      {{- if .Values.DB_VOLUME_NAME}}
      - {{.Values.DB_VOLUME_NAME}}:/var/lib/postgresql/data
      {{- else}}
      - pgdata:/var/lib/postgresql/data
      {{- end }}

volumes:
  {{- if .Values.DB_VOLUME_NAME}}
  {{- else}}
  pgdata:
    driver: local
  {{- end }}
  {{- if .Values.LOG_VOLUME_NAME}}
  {{- else}}
  jfrogdata:
    driver: local
  {{- end }}
