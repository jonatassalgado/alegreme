# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
every 1.day, at: '23:00 pm' do
  rake "db:exists && db:dump"
end

every 1.day, at: '02:00 am' do
  rake "scrapy:facebook"
end

# Learn more: http://github.com/javan/whenever
