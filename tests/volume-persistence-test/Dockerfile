FROM alpine:3.4
RUN mkdir -p /data
ARG ARGVERSION
ENV TEST_VERSION $ARGVERSION
VOLUME /data
CMD touch /data/$TEST_VERSION && while true; do sleep 2; done
