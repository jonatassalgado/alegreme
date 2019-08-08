#!/bin/bash
# Interpreter identifier

set -e
# Exit on fail

# echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p

bundle check || bundle install --binstubs="$BUNDLE_BIN"
# Ensure all gems installed. Add binstubs to bin which has been added to PATH in Dockerfile.

rake db:exists && rake db:migrate || rake db:setup db:migrate

#rake db:exists RAILS_ENV=development && rails runner "Event.reindex"

# whenever --update-crontab

exec "$@"
# Finally call command issued to the docker service
