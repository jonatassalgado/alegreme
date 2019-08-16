#!/bin/bash
# Interpreter identifier

set -e
# Exit on fail

# echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p

bundle check || bundle install --binstubs="$BUNDLE_BIN"

# bundle exec rake webpacker:clobber
# yarn install
# bundle exec rake assets:precompile

rake db:exists && rake db:migrate || rake db:setup db:migrate

#rake db:exists RAILS_ENV=development && rails runner "Event.reindex"

whenever

exec "$@"
# Finally call command issued to the docker service
