version: "2"

services:
  vault:
    {{- if .Values.HOST_AFFINITY_LABEL}}
    labels:
      io.rancher.scheduler.affinity:{{.Values.HOST_AFFINITY_LABEL}}
    {{- end }}
    restart: unless-stopped # required so that it retries until conocurse-db comes up
    image: vault:0.9.0
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
    image: postgres:10.1
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
    {{- if .Values.HOST_AFFINITY_LABEL}}
    labels:
      io.rancher.scheduler.affinity: {{.Values.HOST_AFFINITY_LABEL}}
    {{- end }}
    image: eugenmayer/concourse-configurator
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
      io.rancher.container.pull_image: always
      io.rancher.sidekicks: config
      io.rancher.sidekicks: vault
    {{- if .Values.HOST_AFFINITY_LABEL}}
      io.rancher.scheduler.affinity: {{.Values.HOST_AFFINITY_LABEL}}
    {{- end }}
    image: concourse/concourse:3.8.0
    command: web --vault-ca-cert /vault/client/server.crt --tsa-host-key=/run/secrets/concourse-tsa-private-key --tsa-authorized-keys=/run/secrets/concourse-tsa-authorized-workers --tsa-session-signing-key==/run/secrets/concourse-session-signing-key
    secrets:
      - concourse-tsa-authorized-workers
      - concourse-tsa-private-key
      - concourse-session-signing-key
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
      CONCOURSE_BASIC_AUTH_USERNAME: ${ADMIN_USER}
      CONCOURSE_BASIC_AUTH_PASSWORD: ${ADMIN_PASSWORD}
      CONCOURSE_EXTERNAL_URL: ${CONCOURSE_EXTERNAL_URL}
      CONCOURSE_POSTGRES_HOST: db
      CONCOURSE_POSTGRES_USER: ${DB_USER}
      CONCOURSE_POSTGRES_PASSWORD: ${DB_PASSWORD}
      CONCOURSE_POSTGRES_DATABASE: ${DB_NAME}

      CONCOURSE_TSA_HOST_KEY: /run/secrets/concourse-tsa-private-key
      CONCOURSE_TSA_SESSION_SIGNING_KEY: /run/secrets/concourse-session-signing-key
      CONCOURSE_TSA_AUTHORIZED_KEYS: /run/secrets/concourse-tsa-authorized-workers

      CONCOURSE_VAULT_CA_CERT: /vault/client/server.crt

      CONCOURSE_VAULT_URL: https://vault:8200
      CONCOURSE_VAULT_TLS_INSECURE_SKIP_VERIFY: "true"
      CONCOURSE_VAULT_AUTH_BACKEND: cert
      CONCOURSE_VAULT_PATH_PREFIX: /secret/concourse
      # those keys are generated by the config container
      CONCOURSE_VAULT_CLIENT_CERT: /vault/client/cert.pem
      CONCOURSE_VAULT_CLIENT_KEY: /vault/client/key.pem
  # see https://github.com/concourse/concourse-docker/blob/master/Dockerfile
  worker-standalone:
    labels:
      {{- if .Values.HOST_WORKER_AFFINITY_LABEL}}
      io.rancher.scheduler.affinity: {{.Values.HOST_WORKER_AFFINITY_LABEL}}
      {{- end }}
      io.rancher.container.pull_image: always
    image: eugenmayer/concourse-worker-solid:3.8.0
    privileged: true
    secrets:
      - concourse-worker-private-key
      - concourse-tsa-public-key
    # we need --tsa-worker-private-key=/run/secrets/concourse-worker-private-key --tsa-public-key=/concourse-keys/concourse-tsa-public-key
    # since the ENV variables seem to be buggy and not functional in this case. Those 2 are set in our worker during the startup
    # CONCOURSE_TSA_PUBLIC_KEY=/run/secrets/concourse-tsa-public-key
    # CONCOURSE_TSA_WORKER_PRIVATE_KEY=/run/secrets/concourse-worker-private-key
    # but we get a handshake error, so the private key path seems to not get picked up by the env variable here
    command: retire-worker --tsa-worker-private-key=/run/secrets/concourse-worker-private-key --tsa-public-key=/run/secrets/concourse-tsa-public-key
    environment:
      CONCOURSE_TSA_HOST: tsa
      CONCOURSE_TSA_PORT: 2222
      CONCOURSE_GARDEN_NETWORK_POOL: ${CONCOURSE_GARDEN_NETWORK_POOL}
      CONCOURSE_BAGGAGECLAIM_DRIVER: ${CONCOURSE_BAGGAGECLAIM_DRIVER}
      CONCOURSE_BAGGAGECLAIM_LOG_LEVEL: ${CONCOURSE_BAGGAGECLAIM_LOG_LEVEL}
      CONCOURSE_GARDEN_LOG_LEVEL: ${CONCOURSE_GARDEN_LOG_LEVEL}
      CONCOURSE_TSA_WORKER_PRIVATE_KEY: /run/secrets/concourse-worker-private-key
      CONCOURSE_TSA_PUBLIC_KEY: /run/secrets/concourse-tsa-public-key
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


