version: "2"

services:
  config_worker:
    labels:
      {{- if .Values.HOST_WORKER_AFFINITY_LABEL}}
      io.rancher.scheduler.affinity:{{.Values.HOST_WORKER_AFFINITY_LABEL}}
      {{- end }}
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
      TSA_EXISTING_PUBLIC_KEY: ${TSA_EXISTING_PUBLIC_KEY}
      WORKER_EXISTING_PRIVATE_KEY: ${WORKER_EXISTING_PRIVATE_KEY}

  # see https://github.com/concourse/concourse-docker/blob/master/Dockerfile
  worker-standalone:
    labels:
      {{- if .Values.HOST_WORKER_AFFINITY_LABEL}}
      io.rancher.scheduler.affinity:{{.Values.HOST_WORKER_AFFINITY_LABEL}}
      {{- end }}
      io.rancher.container.pull_image: always
    image: eugenmayer/concourse-worker-solid:3.8.0
    privileged: true
    depends_on:
      - config_worker
    volumes:
      {{- if .Values.WORKER_KEYS_VOLUME_NAME}}
      - {{.Values.WORKER_KEYS_VOLUME_NAME}}:/concourse-keys
      {{- else}}
      - concourse-keys-worker:/concourse-keys
      {{- end }}
    environment:
      CONCOURSE_TSA_HOST: ${CONCOURSE_TSA_HOST}
      CONCOURSE_TSA_PORT: ${CONCOURSE_TSA_PORT}
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
