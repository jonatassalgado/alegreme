#!/bin/bash
# Interpreter identifier

set -e

bundle check || bundle install

exec "$@"
# Finally call command issued to the docker service
