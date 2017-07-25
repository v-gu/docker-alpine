## -*- docker-image-name: lisnaz/alpine -*-
#
# Dockerfile for alpine
#

FROM alpine:3.6
MAINTAINER Vincent Gu <v@vgu.io>

ENV LANG=C.utf8 \
    LC_ALL=C.utf8 \
    INIT_DEBUG=false \
    APP_DIR=/srv

# define WORKDIR
WORKDIR ${APP_DIR}

# define entrypoint
ADD imagescripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

RUN set -ex && \
    DEP='bash gawk' && \
    apk add --update --no-cache $DEP && \
    rm -rf /var/cache/apk/*

# app start-up script should be placed in APP_DIR and named run.sh
