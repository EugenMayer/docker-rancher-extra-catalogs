version: "2"
# https://github.com/jfrog/artifactory-docker-examples/blob/master/docker-compose/artifactory/artifactory-oss-postgresql.yml
services:
  app:
    # https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes
    image: docker.bintray.io/jfrog/artifactory-cpp-ce
    labels:
{{- if .Values.EXTRA_LABELS }}
{{.Values.EXTRA_LABELS | indent 6}}
{{- end}}
      traefik.port: 8082
      traefik.frontend.rule: ${TRAEFIK_FRONTEND_RULE}
      traefik.enable: true
      traefik.acme: ${TRAEFIK_FRONTEND_HTTPS_ENABLE}
      io.rancher.container.create_agent: 'true'
      io.rancher.container.agent.role: 'environment'
      io.rancher.container.pull_image: always
    environment:
      JF_SHARED_DATABASE_TYPE: postgresql
      JF_SHARED_DATABASE_DRIVER: org.postgresql.Driver
      JF_SHARED_DATABASE_USERNAME: ${DB_USER}
      JF_SHARED_DATABASE_PASSWORD: ${DB_PASSWORD}
      JF_SHARED_DATABASE_URL: jdbc:postgresql://db:5432/${DB_NAME}
    volumes:
    {{- if .Values.DATA_VOLUME_NAME}}
    - {{.Values.DATA_VOLUME_NAME}}:/var/opt/jfrog/artifactory
    {{- else}}
    - jfrogdata:/var/opt/jfrog/artifactory
    {{- end }}
  # has to be named postgresql since app expects it and neither DB_URL nor DB_HOSt works
  db:
    image: postgres:12
    {{- if .Values.HOST_AFFINITY_LABEL}}
    labels:
      io.rancher.scheduler.affinity: {{.Values.HOST_AFFINITY_LABEL}}
    {{- end }}
    environment:
      # has to be artifactory since app DB_NAME does not work
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
