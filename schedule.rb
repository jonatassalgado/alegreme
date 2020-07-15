set :output, '/root/alegreme/logs/whenever/cron.log'

every 30.hours do
  command "cd /root/alegreme && sudo docker-compose run --rm scrapy scrapy crawl event -s JOBDIR=crawls/event-1 && sudo docker-compose restart splash"
end

every 23.hours do
  command "cd /root/alegreme && sudo docker exec alegreme_app_1 rake populate:events similar:events suggestions:users sitemap:refresh search:refresh"
end


# every 24.hours do
#   command "cd /root/alegreme && sudo docker-compose run --rm scrapy scrapy crawl movie -s JOBDIR=crawls/movie-1 && sudo docker-compose restart splash"
# end

# every 23.hours do
#   command "cd /root/alegreme && sudo docker exec alegreme_app_1 rake populate:movies"
# end

every 2.weeks do
  command "cd /root/alegreme && sudo docker exec alegreme_app_1 rake populate:movies:new_release"
end

every 2.days do
  command "cd /root/alegreme && > logs/api/error.log"
end

every 1.month do
  command "cd /root/alegreme && sudo ./init-letsencrypt.sh"
end
