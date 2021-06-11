
# Alegreme
Aplicativo com objetivo de fazer as pessoas aproveitarem mais a cidade de Porto Alegre


### Bundle
    Ruby 2.6.3
    Rails 5.2.1


### Anaconda
    conda create --name alegreme python=3
    source activate alegreme

### Scrapy


##### development
    sudo docker run -p 8050:8050 -p 5023:5023 scrapinghub/splash
    scrapy crawl event -s CLOSESPIDER_ITEMCOUNT=5

##### production
    scrapy-do --pidfile -n scrapy-do --config scrapydo.conf
    scrapy-do-cl --url http://159.89.84.18:7654 push-project
    scrapy-do-cl schedule-job --url http://159.89.84.18:7654 --project alegreme --spider event --when 'every day at 01:00'


### Flask

    python ml/api/main.py

### Lightsail

https://lightsail.aws.amazon.com/ls/webapp/home

### Firewall

|ENC|PROT|PORT|SERV|
|--|--|--|--|
SSH| TCP| 22| -
HTTP | TCP | 80 | -
HTTPS | TCP | 443 | -
CUSTOM | TCP | 3000 | RAILS
CUSTOM | TCP | 3030 | API (FLASK)


### SECURE SSH

    apt install fail2ban

    # make a copy of default config (this copy will overload default params according to manual)
    sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

    # restart after edit confs
    sudo service fail2ban restart

    # list rules
    sudo iptables -L

    # banned ips
    sudo zgrep 'Ban' /var/log/fail2ban.log*


### Docker

    docker-compose up -d --build <service_name>
    
Docker stop all
    
    docker kill $(docker ps -q)

### Certbot
    sudo ./init-letsencrypt.sh

-> https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71

* Verificar se arquivos do github estão atualizados


### Whenever
    whenever --update-crontab --load-file /root/alegreme/schedule.rb
    crontab -l
