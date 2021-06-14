set :output, '/root/alegreme/logs/whenever/cron.log'

# Remove deleted events
#every 1.day, at: '11:00 pm' do
#  command "cd /root/alegreme/scrapy && sudo docker-compose run --rm scrapy scrapy crawl deleted_event -s JOBDIR=crawls/deleted-event-1 && sudo docker-compose down"
#end

#every 1.day, at: '11:30 pm' do
#  command "cd /root/alegreme && sudo docker exec alegreme_app_1 bundle exec rake remove:deleted_events similar:events suggestions:users"
#end


# Populate new events
every 1.day, at: ['12:00 pm', '18:00 pm'] do
  command "cd /root/alegreme/scrapy && sudo docker-compose run --rm scrapy scrapy crawl event -s JOBDIR=crawls/event-1 && sudo docker-compose down"
end

every 1.day, at: ['13:30 pm', '19:30 pm'] do
  command "cd /root/alegreme && sudo docker exec alegreme_app_1 bundle exec rake populate:events similar:events suggestions:users sitemap:refresh search:refresh"
end


# DevOps
every 1.day do
  command "cd /root/alegreme && > logs/api/error.log"
end

every 1.month do
  command "cd /root/alegreme && sudo ./init-letsencrypt.sh"
end
