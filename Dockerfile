## -*- docker-image-name: lisnaz/alpine -*-
#
# Dockerfile for alpine
#

FROM alpine:3.5
MAINTAINER Vincent Gu <g@v-io.co>

ENV LANG=C.utf8 \
    LC_ALL=C.utf8 \
    INIT_DEBUG=false \
    APP_BASEDIR=/srv \
    PROC_SCRIPTS_DIR=/srv/_scripts

# define default directory
WORKDIR ${APP_BASEDIR}

# add entrypoint
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

RUN set -ex && \
    DEP=bash && \
    apk add --update --no-cache $DEP && \
    rm -rf /var/cache/apk/*

# Application runtime directory is recommanded to set to /srv/<app_name>.
#
# please define environment variable APP_DIR=/srv/<app_name> and place files
# in it or symlink proper directory to it if needed.

# use environment variables like:
#
#   PROC1=/usr/bin/proc1        # this process's command
#   PROC1_NAME=proc1            # keyword used to check process healthness
#   PROC1_BG=false              # run this process in background or not
#   PROC1_SCRIPT_DIRNAME=<name> # optional, defaults to PROC_NAME. located at
#                               # ${PROC_SCRIPTS_DIR}/<name>, and
#                               # ${PROC_SCRIPTS_DIR}/<name>/main.sh will be
#                               # executed when container startup.
#
# to start processes.
# Increase suffix number as your wish as there are more processes.
#
# if only one process to be executed, only PROC1= is required.
