
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
    scrapy crawl event -s CLOSESPIDER_ITEMCOUNT=25

##### production
    scrapy-do-cl --url http://3.223.33.161:7654 push-project
    scrapy-do-cl schedule-job --url http://3.223.33.161:7654 --project alegreme --spider event --when 'every day at 01:00'


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



### Docker

    docker-compose up -d --build <service_name>

### Certbot
    sudo ./init-letsencrypt.sh

-> https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71

* Verificar se arquivos do github estão atualizados


### Whenever
    web/config/schedule.rb
