set :output, '/root/alegreme/logs/whenever/cron.log'

every 2.hours do
  command "cd /root/alegreme && sudo docker-compose run --rm scrapy scrapy crawl event -s JOBDIR=crawls/event-1 && sudo docker-compose restart splash"
end

every 1.hour do
  command "cd /root/alegreme && sudo docker exec alegreme_app_1 rake populate:facebook similar:events suggestions:users sitemap:refresh search:refresh"
end

every 8.hours do
  command "cd /root/alegreme && sudo docker-compose run --rm scrapy scrapy crawl movie -s JOBDIR=crawls/movie-1"
end

every 4.hour do
  command "cd /root/alegreme && sudo docker exec alegreme_app_1 rake populate:movies"
end

every 1.day do
  command "cd /root/alegreme && > logs/api/error.log"
end
