require 'clockwork'
require 'active_support/time' # Allow numeric durations (eg: 1.minutes)
require 'rake'

require '/var/www/alegreme/config/boot'
require '/var/www/alegreme/config/environment'

App::Application.load_tasks

module Clockwork
  configure do |config|
    config[:logger] = Logger.new('log/clockwork.log')
    config[:tz] = 'America/Sao_Paulo'
    config[:max_threads] = 4
    config[:thread] = true
  end

  handler do |job|
    puts "Running #{job}"
  end

  if Rails.env != 'test'
    every(1.day, 'db:dump', :at => '23:00') {
      Rake::Task["db:dump"].invoke
    }

    # every(1.day, 'push:new_events_today', :at => '12:15') {
    #   Rake::Task["push:new_events_today"].invoke
    # }
    #
    # every(1.day, 'push:saved_events_tomorrow', :at => '21:15') {
    #   Rake::Task["push:saved_events_tomorrow"].invoke
    # }
    #
    # every(3.hours, 'push:saved_events_shortly') {
    #   Rake::Task["push:saved_events_shortly"].invoke
    # }
    #
    # every(7.days, 'populate:movies:new_release') {
    #   Rake::Task["populate:movies:new_release"].invoke
    # }
  end

end
