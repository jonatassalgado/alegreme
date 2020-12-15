#!/bin/bash
# Interpreter identifier

set -e
# Exit on fail

bundle check || bundle install --binstubs="$BUNDLE_BIN"
yarn install
rake db:exists && rake db:migrate
bundle exec rake search:refresh

exec "$@"
# Finally call command issued to the docker service
