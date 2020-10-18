APP := app
SERVICE := alegreme_app_1
RUN := docker-compose -f docker-compose.development.yml run --rm $(APP)
EXEC := docker exec -it $(SERVICE)
ENV := development


run:
	$(RUN) $(command)

build:
	docker-compose -f docker-compose.development.yml up --build

build-service:
	docker-compose -f docker-compose.development.yml up -d --no-deps --build $(APP)

up:
	docker-compose -f docker-compose.development.yml up -d

up-scrapy:
	docker-compose -f docker-compose.development.scrapy.yml up -d

restart:
	docker-compose -f docker-compose.development.yml restart

down:
	docker-compose -f docker-compose.development.yml down

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
	$(RUN) bash -c "rm /var/www/alegreme/db/schema.rb && rake db:drop"

db-create:
	$(RUN) bash -c "rake db:migrate && rake db:seed"

credentials:
	$(EXEC) bash -c "EDITOR=nano rails credentials:edit"

docker-run-scrapy:
	docker-compose -f docker-compose.development.scrapy.yml run --rm scrapy bash

scrapy-run-test:
	docker exec alegreme_scrapy_1 bash -c "scrapy crawl event -s CLOSESPIDER_ITEMCOUNT=10"

scrapy-push-project:
	docker exec -it alegreme_scrapy_1 bash -c "scrapy-do-cl --username jon --password password --url http://159.89.84.18:7654 push-project"

scrapy-schedule-job:
	docker exec -it alegreme_scrapy_1 bash -c "scrapy-do-cl --username jon --password password --url http://159.89.84.18:7654 schedule-job --project alegreme --spider event --when 'every day at 01:00'"

test:
	$(RUN) bash -c "rails test"

restore-backup:
	$(RUN) bash -c "rake restore:backup"

cloud:
	ssh root@159.89.84.18

prune:
	docker image prune
	docker volume prune
	docker container prune

hint:
	hint http://localhost:3000
