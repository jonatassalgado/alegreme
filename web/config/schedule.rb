# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#

ENV.each { |k, v| env(k, v) }

set :output, "/var/www/alegreme/log/cron.log"

every 1.hour do
  command '/bin/echo "hello"'
end

every 6.hour do
  rake "db:dump"
end

every 1.day, at: '11:00 pm' do
  rake "populate:facebook similar:events"
end


# Learn more: http://github.com/javan/whenever
