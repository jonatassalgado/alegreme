# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#

ENV.each { |k, v| env(k, v) }

set :output, "/var/www/alegreme/log/cron_log.log"

# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
every 1.day, at: '1:00 am' do
  rake "db:dump"
end

every 1.day, at: '04:00 am' do
  rake "populate:facebook similar:events"
end

# Learn more: http://github.com/javan/whenever
