version: "2"

services:
  vault:
    {{- if .Values.HOST_AFFINITY_LABEL}}
    labels:
      io.rancher.scheduler.affinity:{{.Values.HOST_AFFINITY_LABEL}}
    {{- end }}
    restart: unless-stopped # required so that it retries until conocurse-db comes up
    image: vault:1.2.0
    cap_add:
     - IPC_LOCK
    depends_on:
     - config
    command: vault server -config /vault/config/vault.hcl {{.Values.VAULT_START_PARAMS}}
    volumes:
      {{- if .Values.VAULT_SERVER_CONFIG_VOLUME_NAME}}
      - {{.Values.VAULT_SERVER_CONFIG_VOLUME_NAME}}:/vault/config
      {{- else}}
      - vault-server-config:/vault/config
      {{- end }}
      {{- if .Values.VAULT_SERVER_DATA_VOLUME_NAME}}
      - {{.Values.VAULT_SERVER_DATA_VOLUME_NAME}}:/vault/file
      {{- else}}
      - vault-server-data:/vault/file
      {{- end }}

  db:
    {{- if .Values.HOST_AFFINITY_LABEL}}
    labels:
      io.rancher.scheduler.affinity: {{.Values.HOST_AFFINITY_LABEL}}
    {{- end }}
    image: postgres:11
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

  config:
    labels:
{{- if .Values.HOST_AFFINITY_LABEL}}
      io.rancher.scheduler.affinity: {{.Values.HOST_AFFINITY_LABEL}}
{{- end }}
      io.rancher.container.pull_image: always
    image: eugenmayer/concourse-configurator:5.x
    volumes:
      {{- if .Values.VAULT_CLIENT_CONFIG_VOLUME_NAME}}
      - {{.Values.VAULT_CLIENT_CONFIG_VOLUME_NAME}}:/vault/concourse
      {{- else}}
      - vault-client-config:/vault/concourse
      {{- end }}
      {{- if .Values.VAULT_SERVER_CONFIG_VOLUME_NAME}}
      - {{.Values.VAULT_SERVER_CONFIG_VOLUME_NAME}}:/vault/server
      {{- else}}
      - vault-server-config:/vault/server
      {{- end }}
    restart: unless-stopped
    environment:
      DO_GENERATE_TSA_KEYS: 0
      DO_GENERATE_WORKER_KEYS: 0
      VAULT_ENABLED: 1
      VAULT_DO_AUTOCONFIGURE: 1

  # see https://github.com/concourse/concourse-docker/blob/master/Dockerfile
  tsa:
    labels:
{{- if .Values.EXTRA_LABELS }}
{{.Values.EXTRA_LABELS | indent 6}}
{{- end}}
      io.rancher.container.pull_image: always
      io.rancher.sidekicks: config, vault
      traefik.enable: true
      traefik.port: 8080
      traefik.frontend.rule: ${TRAEFIK_FRONTEND_RULE}
      traefik.acme: ${TRAEFIK_FRONTEND_HTTPS_ENABLE}
    {{- if .Values.HOST_AFFINITY_LABEL}}
      io.rancher.scheduler.affinity: {{.Values.HOST_AFFINITY_LABEL}}
    {{- end }}
    image: concourse/concourse:5.4.0
    command: web --enable-global-resources
    {{- if .Values.TSA_HOST_EXPOSE_PORT }}
    ports:
    - ${TSA_HOST_EXPOSE_PORT}:2222
    {{- end }}
    secrets:
      - concourse-tsa-authorized-workers
      - concourse-tsa-private-key
      - concourse-tsa-session-signing-key
    depends_on:
      - config
      - db
      - vault
    volumes:
      {{- if .Values.VAULT_CLIENT_CONFIG_VOLUME_NAME}}
      - {{.Values.VAULT_CLIENT_CONFIG_VOLUME_NAME}}:/vault/client
      {{- else}}
      - vault-client-config:/vault/client
      {{- end }}
    restart: unless-stopped # required so that it retries until conocurse-db comes up
    environment:
      CONCOURSE_LOG_LEVEL: ${CONCOURSE_LOG_LEVEL}
      # that seems to be important otherwise the workers seem to malfunction
      # most probably trying to use the CONCOURSE_EXTERNAL_URL for the connection, which might be inaccesible
      # if it is on a private network and the worker is outside this e.g. hosted on vultr
      # but between all hosts we have an automatic ipsec based network which services can use to communicate
      CONCOURSE_TSA_ATC_URL: ${TSA_ATC_URL}
      CONCOURSE_TSA_PEER_IP: ${TSA_PEER_IP}
      CONCOURSE_TSA_LOG_LEVEL: ${CONCOURSE_TSA_LOG_LEVEL}
      CONCOURSE_TSA_AUTHORIZED_KEYS: /run/secrets/concourse-tsa-authorized-workers
      CONCOURSE_TSA_HEARTBEAT_INTERVAL: ${CONCOURSE_TSA_HEARTBEAT_INTERVAL}
      CONCOURSE_TSA_HOST_KEY: /run/secrets/concourse-tsa-private-key
      # its not, even though it should be CONCOURSE_TSA_SESSION_SIGNING_KEY according to `concourse web --help`
      CONCOURSE_SESSION_SIGNING_KEY: /run/secrets/concourse-tsa-session-signing-key
      CONCOURSE_AUTH_DURATION: ${CONCOURSE_AUTH_DURATION}

      {{- if eq .Values.AUTH_BACKEND "local" }}
      CONCOURSE_ADD_LOCAL_USER: "${LOCAL_ADMIN_USER}:${LOCAL_ADMIN_PASSWORD}"
      CONCOURSE_MAIN_TEAM_LOCAL_USER: "${LOCAL_ADMIN_USER}"
      {{- end }}

      {{- if eq .Values.AUTH_BACKEND "ldap" }}
      # for docs see https://github.com/EugenMayer/concourseci-server-boilerplate/blob/master/docker-compose-ldap-auth.yml
      CONCOURSE_LDAP_DISPLAY_NAME: "LDAP"

      CONCOURSE_LDAP_HOST: ${CONCOURSE_LDAP_HOST}
      CONCOURSE_LDAP_BIND_DN: ${CONCOURSE_LDAP_BIND_DN}
      CONCOURSE_LDAP_BIND_PW: ${CONCOURSE_LDAP_BIND_PW}
      CONCOURSE_LDAP_INSECURE_NO_SSL: "${CONCOURSE_LDAP_INSECURE_NO_SSL}"
      CONCOURSE_LDAP_START_TLS: "${CONCOURSE_LDAP_START_TLS}"
      CONCOURSE_LDAP_INSECURE_SKIP_VERIFY: "${CONCOURSE_LDAP_INSECURE_SKIP_VERIFY}"

      CONCOURSE_LDAP_USER_SEARCH_BASE_DN: "${CONCOURSE_LDAP_USER_SEARCH_BASE_DN}"
      CONCOURSE_LDAP_USER_SEARCH_USERNAME: ${CONCOURSE_LDAP_USER_SEARCH_USERNAME}
      CONCOURSE_LDAP_USER_SEARCH_ID_ATTR: ${CONCOURSE_LDAP_USER_SEARCH_ID_ATTR}
      CONCOURSE_LDAP_USER_SEARCH_EMAIL_ATTR: ${CONCOURSE_LDAP_USER_SEARCH_EMAIL_ATTR}
      CONCOURSE_LDAP_USER_SEARCH_NAME_ATTR: ${CONCOURSE_LDAP_USER_SEARCH_NAME_ATTR}
      CONCOURSE_LDAP_USER_SEARCH_SCOPE: ${CONCOURSE_LDAP_USER_SEARCH_SCOPE}
      CONCOURSE_LDAP_USER_SEARCH_FILTER: "${CONCOURSE_LDAP_USER_SEARCH_FILTER}"

      CONCOURSE_LDAP_GROUP_SEARCH_BASE_DN: "${CONCOURSE_LDAP_GROUP_SEARCH_DN}"
      CONCOURSE_LDAP_GROUP_SEARCH_NAME_ATTR: ${CONCOURSE_LDAP_GROUP_SEARCH_NAME_ATTR}
      CONCOURSE_LDAP_GROUP_SEARCH_SCOPE: ${CONCOURSE_LDAP_GROUP_SEARCH_SCOPE}
      CONCOURSE_LDAP_GROUP_SEARCH_USER_ATTR: ${CONCOURSE_LDAP_GROUP_SEARCH_USER_ATTR}
      CONCOURSE_LDAP_GROUP_SEARCH_GROUP_ATTR: ${CONCOURSE_LDAP_GROUP_SEARCH_GROUP_ATTR}
      CONCOURSE_LDAP_GROUP_SEARCH_FILTER: ${CONCOURSE_LDAP_GROUP_SEARCH_FILTER}

      CONCOURSE_MAIN_TEAM_LDAP_USER: "${CONCOURSE_MAIN_TEAM_LDAP_USER}"
      CONCOURSE_MAIN_TEAM_LDAP_GROUP: "${CONCOURSE_MAIN_TEAM_LDAP_GROUP}"
      {{- end }}

      CONCOURSE_EXTERNAL_URL: ${CONCOURSE_EXTERNAL_URL}
      CONCOURSE_POSTGRES_HOST: db
      CONCOURSE_POSTGRES_USER: ${DB_USER}
      CONCOURSE_POSTGRES_PASSWORD: ${DB_PASSWORD}
      CONCOURSE_POSTGRES_DATABASE: ${DB_NAME}

      CONCOURSE_VAULT_URL: https://vault:8200
      CONCOURSE_VAULT_TLS_INSECURE_SKIP_VERIFY: "true"
      CONCOURSE_VAULT_AUTH_BACKEND: cert
      CONCOURSE_VAULT_PATH_PREFIX: /secret/concourse
      # those keys are generated by the config container
      CONCOURSE_VAULT_CLIENT_CERT: /vault/client/cert.pem
      CONCOURSE_VAULT_CLIENT_KEY: /vault/client/key.pem
      CONCOURSE_VAULT_CA_CERT: /vault/client/server.crt
      CONCOURSE_VAULT_CACHE: 1
      CONCOURSE_RESOURCE_CHECKING_INTERVAL: 10m

{{- if eq .Values.START_INCLUDED_WORKERS "true" }}
  # see https://github.com/concourse/concourse-docker/blob/master/Dockerfile
  worker-standalone:
    #cpu_quota: 100000
    #cpu_period: 180000
    {{- if .Values.RANCHER_WORKER_LIMIT_MEMORY}}
    #mem_reservation: ${RANCHER_WORKER_LIMIT_MEMORY}
    mem_limit: ${RANCHER_WORKER_LIMIT_MEMORY}
    {{- end }}
    {{- if .Values.RANCHER_WORKER_LIMIT_CPU_RESERVATION}}
    cpu_shares: ${RANCHER_WORKER_LIMIT_CPU_RESERVATION}
    {{- end }}
    labels:
      {{- if .Values.HOST_WORKER_AFFINITY_LABEL}}
      io.rancher.scheduler.affinity: {{.Values.HOST_WORKER_AFFINITY_LABEL}}
      {{- end }}
      io.rancher.container.pull_image: always
    image: concourse/concourse:5.4.0
    privileged: true
    secrets:
      - concourse-worker-private-key
      - concourse-tsa-public-key
    command: worker
    environment:
      CONCOURSE_GARDEN_PERSISTENT_IMAGE: ${CONCOURSE_GARDEN_PERSISTENT_IMAGE}
      CONCOURSE_TSA_HOST: ${TSA_PEER_IP}:2222
      CONCOURSE_TSA_LOG_LEVEL: ${CONCOURSE_TSA_LOG_LEVEL}
      CONCOURSE_GARDEN_NETWORK_POOL: ${CONCOURSE_GARDEN_NETWORK_POOL}
      CONCOURSE_BAGGAGECLAIM_DRIVER: ${CONCOURSE_BAGGAGECLAIM_DRIVER}
      CONCOURSE_BAGGAGECLAIM_LOG_LEVEL: ${CONCOURSE_BAGGAGECLAIM_LOG_LEVEL}
      CONCOURSE_GARDEN_LOG_LEVEL: ${CONCOURSE_GARDEN_LOG_LEVEL}
      CONCOURSE_TSA_WORKER_PRIVATE_KEY: /run/secrets/concourse-worker-private-key
      CONCOURSE_TSA_PUBLIC_KEY: /run/secrets/concourse-tsa-public-key

      CONCOURSE_GARDEN_PERSISTENT_IMAGE: ${WORKER_KEEP_IMAGES}

      CONCOURSE_GARDEN_MAX_CONTAINERS: ${CONCOURSE_GARDEN_MAX_CONTAINERS}
      CONCOURSE_GARDEN_CPU_QUOTA_PER_SHARE: ${CONCOURSE_GARDEN_CPU_QUOTA_PER_SHARE}
{{- end }}
{{- if eq .Values.START_INCLUDED_MINIO_S3 "true" }}
  minio:
    image: minio/minio
    command: server /data
    volumes:
      {{- if .Values.MINIO_DATA_VOLUME_NAME}}
      - {{.Values.MINIO_DATA_VOLUME_NAME}}:/data
      {{- else}}
      - minio-data:/data
      {{- end }}
      - minio-config:/root/.minio
    environment:
      MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY}
      MINIO_SECRET_KEY: ${MINIO_SECRET_KEY}
    labels:
      io.rancher.container.pull_image: always
      traefik.enable: true
      traefik.port: 9000
      traefik.frontend.rule: ${TRAEFIK_FRONTEND_RULE_MINIO}
      traefik.acme: ${TRAEFIK_FRONTEND_HTTPS_ENABLE}
{{- end }}

volumes:
  {{- if .Values.DB_VOLUME_NAME}}
  {{- else}}
  pgdata:
    driver: local
  {{- end }}

  {{- if .Values.WEB_KEYS_VOLUME_NAME}}
  {{- else}}
  concourse-keys-web:
    driver: local
  {{- end }}

  {{- if .Values.WORKER_KEYS_VOLUME_NAME}}
  {{- else}}
  concourse-keys-worker:
    driver: local
  {{- end }}

  {{- if .Values.VAULT_SERVER_DATA_VOLUME_NAME}}
  {{- else}}
  vault-server-data:
    driver: local
  {{- end }}

  {{- if .Values.VAULT_SERVER_CONFIG_VOLUME_NAME}}
  {{- else}}
  vault-server-config:
    driver: local
  {{- end }}

  {{- if .Values.VAULT_CLIENT_CONFIG_VOLUME_NAME}}
  {{- else}}
  vault-client-config:
    driver: local
  {{- end }}

{{- if eq .Values.START_INCLUDED_MINIO_S3 "true" }}
  {{- if .Values.MINIO_DATA_VOLUME_NAME}}
  {{- else}}
  minio-data:
    driver: local
  {{- end }}
  minio-config:
    driver: local
{{- end }}

secrets:
  concourse-tsa-private-key:
    external: true
  concourse-tsa-public-key:
    external: true
  concourse-tsa-session-signing-key:
    external: true
  concourse-tsa-authorized-workers:
    external: true
  concourse-worker-private-key:
    external: true
