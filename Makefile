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

restart:
	docker-compose -f docker-compose.development.yml restart

down:
	docker-compose -f docker-compose.development.yml down

console:
	$(EXEC) bash

tail:
	tail -f logs/app/sidekiq.log  logs/app/development.log logs/sidekiq/development.log

debug-app:
	docker attach alegreme_app_1

logs:
	$(EXEC) bash -c "tail -f log/development.log"

remove-volumes:
	docker-compose -f docker-compose.development.yml down -v

db-drop:
	$(RUN) bash -c "rm /var/www/alegreme/db/schema.rb && rake db:drop"

db-create:
	$(RUN) bash -c "rake db:migrate && rake db:seed"

credentials:
	$(EXEC) bash -c "EDITOR=vim rails credentials:edit"

scrapy-run:
	docker exec alegreme_scrapy_1 bash -c "scrapy crawl event"

scrapy-run-test:
	docker exec alegreme_scrapy_1 bash -c "scrapy crawl event -s CLOSESPIDER_ITEMCOUNT=10"

scrapy-up:
	docker exec alegreme_scrapy_1 bash -c "scrapy-do --nodaemon --pidfile= scrapy-do --config scrapydo.conf"

scrapy-push-project:
	docker exec -it alegreme_scrapy_1 bash -c "scrapy-do-cl --username jon --password password --url http://159.89.84.18:7654 push-project"

scrapy-schedule-job:
	docker exec -it alegreme_scrapy_1 bash -c "scrapy-do-cl --username jon --password password --url http://159.89.84.18:7654 schedule-job --project alegreme --spider event --when 'every day at 01:00'"

test:
	$(RUN) bash -c "rails test"

aws:
	ssh ubuntu@159.89.84.18

prune:
	docker image prune
	docker volume prune
	docker container prune
