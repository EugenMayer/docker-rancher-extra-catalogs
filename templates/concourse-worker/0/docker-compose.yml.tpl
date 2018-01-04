version: "2"

services:
  config:
    labels:
      io.rancher.container.pull_image: always
    image: eugenmayer/concourse-worker-configurator
    volumes:
      {{- if .Values.WORKER_KEYS_VOLUME_NAME}}
      - {{.Values.WORKER_KEYS_VOLUME_NAME}}:/concourse-keys/worker
      {{- else}}
      - concourse-keys-worker:/concourse-keys/worker
      {{- end }}
    restart: unless-stopped
    environment:
      TSA_PUBLIC_KEY: ${TSA_PUBLIC_KEY}
      TSA_PRIVATE_KEY: ${TSA_PRIVATE_KEY}

  # see https://github.com/concourse/concourse-docker/blob/master/Dockerfile
  worker:
    labels:
      io.rancher.container.pull_image: always
    image: eugenmayer/concourse-worker-solid:3.8.0
    privileged: true
    depends_on:
      - config
      - web
    volumes:
      {{- if .Values.WORKER_KEYS_VOLUME_NAME}}
      - {{.Values.WORKER_KEYS_VOLUME_NAME}}:/concourse-keys
      {{- else}}
      - concourse-keys-worker:/concourse-keys
      {{- end }}
    environment:
      CONCOURSE_TSA_HOST: ${TSA_HOST}
      CONCOURSE_TSA_PORT: ${TSA_PORT}
      CONCOURSE_GARDEN_NETWORK_POOL: ${CONCOURSE_GARDEN_NETWORK_POOL}
      CONCOURSE_BAGGAGECLAIM_DRIVER: ${CONCOURSE_BAGGAGECLAIM_DRIVER}
      CONCOURSE_BAGGAGECLAIM_LOG_LEVEL: ${CONCOURSE_BAGGAGECLAIM_LOG_LEVEL}
      CONCOURSE_GARDEN_LOG_LEVEL: ${CONCOURSE_GARDEN_LOG_LEVEL}

volumes:
  {{- if .Values.WORKER_KEYS_VOLUME_NAME}}
  {{- else}}
  concourse-keys-worker:
    driver: local
  {{- end }}
