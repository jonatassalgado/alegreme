#!/bin/bash
# Interpreter identifier

set -e
# Exit on fail

# echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p

bundle check || bundle install --binstubs="$BUNDLE_BIN"

rake db:exists && rake db:migrate || rake db:setup db:migrate

#rake db:exists RAILS_ENV=development && rails runner "Event.reindex"

bundle exec clockworkd -c clock.rb -d /var/www/alegreme --log-dir /var/www/alegreme/log --log start

bundle exec rake webpacker:compile
bundle exec rake assets:precompile
# yarn install

exec "$@"
# Finally call command issued to the docker service
