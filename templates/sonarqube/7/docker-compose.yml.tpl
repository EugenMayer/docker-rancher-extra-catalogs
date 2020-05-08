version: "2"

services:
  app:
    image: sonarqube:8.3-community
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
      SONAR_JDBC_USERNAME: ${DB_USER}
      SONAR_JDBC_PASSWORD: ${DB_PASSWORD}
      SONAR_JDBC_URL: "jdbc:postgresql://db:5432/${DB_NAME}"
    volumes:
    {{- if .Values.LOG_VOLUME_NAME}}
    - {{.Values.LOG_VOLUME_NAME}}:/opt/sonarqube/logs
    {{- else}}
    - sonarqubelog:/opt/sonarqube/logs
    {{- end }}
    {{- if .Values.DATA_VOLUME_NAME}}
    - {{.Values.DATA_VOLUME_NAME}}:/opt/sonarqube/data
    {{- else}}
    - sonarqubedata:/opt/sonarqube/data
    {{- end }}
    {{- if .Values.CONF_VOLUME_NAME}}
    - {{.Values.CONF_VOLUME_NAME}}:/opt/sonarqube/conf
    {{- else}}
    - sonarqubeconf:/opt/sonarqube/conf
    {{- end }}
    {{- if .Values.EXTENSIONS_VOLUME_NAME}}
    - {{.Values.EXTENSIONS_VOLUME_NAME}}:/opt/sonarqube/extensions
    {{- else}}
    - sonarqubeextensions:/opt/sonarqube/extensions
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
  sonarqubelog:
    driver: local
  {{- end }}
  {{- if .Values.DATA_VOLUME_NAME}}
  {{- else}}
  sonarqubedata:
    driver: local
  {{- end }}
  {{- if .Values.CONF_VOLUME_NAME}}
  {{- else}}
  sonarqubeconf:
    driver: local
  {{- end }}
  {{- if .Values.EXTENSIONS_VOLUME_NAME}}
  {{- else}}
  sonarqubeextensions:
    driver: local
  {{- end }}
