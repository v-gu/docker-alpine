#!/usr/bin/env bash

if [ "${INIT_DEBUG}" == true ]; then
    set -x
fi

exec ${APP_DIR}/run.sh
