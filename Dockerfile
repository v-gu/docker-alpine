## -*- docker-image-name: lisnaz/alpine -*-
#
# Dockerfile for alpine
#

FROM alpine:3.5
MAINTAINER Vincent.Gu <g@v-io.co>

ENV LANG=C.utf8 \
    LC_ALL=C.utf8 \
    TZ=Asia/Hong_Kong

# define default directory
WORKDIR /srv

# change timezone accordingly
ONBUILD RUN \
  apk --update --no-cache add tzdata && \
  cp /usr/share/zoneinfo/$TZ /etc/localtime && \
  echo "$TZ" > /etc/timezone && \
  apk del --purge tzdata

# add entrypoint
ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

# use environment variables like:
#
#   PROC1=/usr/bin/proc1
#   PROC1_NAME=proc1
#   PROC1_BG=false
#
# to start processes.
# Increase suffix number as your wish as there are more processes.
#
# if only one process to be executed, only PROC1= is required.
