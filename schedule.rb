set :output, '/root/alegreme/logs/whenever/cron.log'

every 1.day, at: '00:30 am' do
  command "cd /root/alegreme/scrapy && sudo docker-compose run --rm scrapy scrapy crawl deleted_event -s JOBDIR=crawls/deleted-event-1 && sudo docker-compose down"
end

every 1.day, at: '02:00 am' do
  command "cd /root/alegreme/scrapy && sudo docker-compose run --rm scrapy scrapy crawl event -s JOBDIR=crawls/event-1 && sudo docker-compose down"
end

every 1.day, at: '05:30 am' do
  command "cd /root/alegreme && sudo docker exec alegreme_app_1 bundle exec rake populate:events similar:events suggestions:users sitemap:refresh search:refresh"
end

every 1.day do
  command "cd /root/alegreme && > logs/api/error.log"
end

every 1.month do
  command "cd /root/alegreme && sudo ./init-letsencrypt.sh"
end
