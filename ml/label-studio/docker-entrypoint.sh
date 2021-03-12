#!/bin/bash
# Interpreter identifier

set -e
# Exit on fail


exec "$@"
# Finally call command issued to the docker service
