#!/bin/bash
# Interpreter identifier

set -e
# Exit on fail

# echo fs.inotify.max_user_watches=52exit4288 | tee -a /etc/sysctl.conf && sysctl -p

bundle check || bundle install --binstubs="$BUNDLE_BIN"

yarn install

rake db:exists && rake db:migrate || rake db:setup db:migrate

# bundle exec rake sitemap:refresh

# bundle exec rake search:refresh

bundle exec clockworkd -c clock.rb -d /var/www/alegreme --log-dir /var/www/alegreme/log --log restart

exec "$@"
# Finally call command issued to the docker service
