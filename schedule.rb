every 1.day, at: '7:00 am' do
  command "cd /root/alegreme && sudo docker-compose restart scrapy"
  command "cd /root/alegreme && sudo docker-compose restart splash"
end
