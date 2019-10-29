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

  # every(5.seconds, 'test') {
  #   puts "teste #{DateTime.now.strftime("%Y%m%d-%H%M%S")}"
  # }

  every(1.day, 'db:dump', :at => '23:00') {
    Rake::Task["db:dump"].invoke
  }

  every(1.day, 'populate:facebook', :at => '06:00') {
    Rake::Task["populate:facebook"].invoke
    Rake::Task["similar:events"].invoke
    Rake::Task["suggestions:users"].invoke
    Rake::Task["sitemap:refresh"].invoke
    Rake::Task["search:refresh"].invoke
  }

  every(1.day, 'push', :at => '09:15') {
    Rake::Task["push:new_events_today"].invoke
  }

  every(1.day, 'push', :at => '17:05') {
    Rake::Task["push:saved_events_tomorrow"].invoke
  }

end
