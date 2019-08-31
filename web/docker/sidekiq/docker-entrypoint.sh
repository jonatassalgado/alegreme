#!/bin/bash
# Interpreter identifier

set -e

bundle check || bundle install --binstubs="$BUNDLE_BIN"

exec "$@"
# Finally call command issued to the docker service
