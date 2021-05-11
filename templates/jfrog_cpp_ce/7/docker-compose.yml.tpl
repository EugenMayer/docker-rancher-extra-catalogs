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
      traefik.port: 8081
      traefik.frontend.rule: ${TRAEFIK_FRONTEND_RULE}
      traefik.enable: true
      traefik.acme: ${TRAEFIK_FRONTEND_HTTPS_ENABLE}
      io.rancher.container.create_agent: 'true'
      io.rancher.container.agent.role: 'environment'
      io.rancher.container.pull_image: always
    environment:
      DB_TYPE: postgresql
      # not working
      #DB_HOST: db
      # not working
      #DB_PORT: 5432
      # not working
      #DB_URL: jdbc:postgresql://db:5432/artifactory
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
    volumes:
    {{- if .Values.DATA_VOLUME_NAME}}
    - {{.Values.DATA_VOLUME_NAME}}:/var/opt/jfrog/artifactory
    {{- else}}
    - jfrogdata:/var/opt/jfrog/artifactory
    {{- end }}
  # has to be named postgresql since app expects it and neither DB_URL nor DB_HOSt works
  postgresql:
    image: postgres:10
    environment:
      # has to be artifactory since app DB_NAME does not work
      POSTGRES_DB: artifactory
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
