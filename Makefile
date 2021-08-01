APP := app
SERVICE := alegreme_app_1
RUN := docker-compose -f docker-compose.development.yml run --rm $(APP)
EXEC := docker exec -it $(SERVICE)
ENV := development


run:
	$(RUN) $(command)

run-scrapy:
	docker-compose -f docker-compose.development.scrapy.yml run --rm scrapy bash

build:
	docker-compose -f docker-compose.development.yml up -d --build

build-service:
	docker-compose -f docker-compose.development.yml up -d --no-deps --build $(APP)

up:
	docker-compose -f docker-compose.development.yml up -d

up-service:
	docker-compose -f docker-compose.development.yml up -d $(APP)

up-clean-entrypoint:
	docker run -it --entrypoint /bin/bash alegreme_app

up-scrapy:
	docker-compose -f docker-compose.development.scrapy.yml up -d

up-crontab-ui:
	docker run -e BASIC_AUTH_USER=jonataseduardo -e BASIC_AUTH_PWD=REMOVED -d -p 8001:8000 --name="crontab-ui" --restart=always --memory="512m" --cpus="1" alseambusher/crontab-ui

down-crontab-ui:
	docker stop crontab-ui

up-splash:
	cd scrapy && docker-compose up splash

down-splash:
	cd scrapy && docker-compose down

restart:
	docker-compose -f docker-compose.development.yml restart

down:
	docker-compose -f docker-compose.development.yml down --remove-orphans

ps:
	docker-compose -f docker-compose.development.yml ps

console:
	$(EXEC) bash

console-scrapy:
	docker exec -it alegreme_scrapy_1 bash

tail:
	tail -f logs/app/sidekiq.log  logs/app/development.log logs/sidekiq/development.log

debug-app:
	docker attach alegreme_app_1

webpack-watcher:
	$(EXEC) bash -c "./bin/webpack --watch --colors --progress"

logs:
	$(EXEC) bash -c "tail -f log/development.log"

remove-volumes:
	docker-compose -f docker-compose.development.yml down -v

db-drop:
	$(RUN) bash -c "rm /var/www/alegreme/db/schema.rb && bundle exec rake db:drop"

db-create:
	$(RUN) bash -c "bundle exec rake db:migrate && bundle exec rake db:seed"

db-restore-backup:
	$(RUN) bash -c "bundle exec rake restore:backup"

credentials:
	$(EXEC) bash -c "EDITOR=nano rails credentials:edit"

restart-docker-service:
	systemctl restart docker.socket docker.service

test:
	$(RUN) bash -c "rails test"

cloud:
	ssh root@159.89.84.18

ngrok-splash:
	ngrok http --region=sa -subdomain=724980c0dcd02d8fda535068339fb6fbebf437d6a9 8050

ngrok-flutter:
	ngrok http --region=sa -subdomain=flutter-724980c0dcd02d8fda535068339fb6fbebf437d6a9 3000

prune:
	docker image prune --filter="dangling=true"
	docker volume prune
	docker container prune

hint:
	hint http://localhost:3000

crontab-update:
	whenever --update-crontab --load-file ./schedule.rb

crontab-list:
	crontab -l