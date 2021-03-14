#!/bin/bash

label-studio start ${PROJECT_NAME:-project} -b \
    --host ${HOST:-0.0.0.0} --port ${PORT:-8080} --protocol ${PROTOCOL:-http://} \
    --username ${USERNAME:-""} --password ${PASSWORD:-""}

