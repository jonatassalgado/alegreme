APP := app
SERVICE := alegreme_app_1
RUN := docker-compose -f docker-compose.development.yml run --rm $(APP)
EXEC := docker exec -it $(SERVICE)
ENV := development


run:
	$(RUN) $(command)

build:
	docker-compose -f docker-compose.development.yml up -d --build

build-service:
	docker-compose -f docker-compose.development.yml up -d --no-deps --build $(APP)

up:
	docker-compose -f docker-compose.development.yml up -d

up-clean-entrypoint:
	docker run -it --entrypoint /bin/bash alegreme_app

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

run-scrapy:
	docker-compose -f docker-compose.development.scrapy.yml run --rm scrapy bash

restart-docker-service:
	systemctl restart docker.socket docker.service

test:
	$(RUN) bash -c "rails test"

restore-backup:
	$(RUN) bash -c "rake restore:backup"

cloud:
	ssh root@159.89.84.18

prune:
	docker image prune --filter="dangling=true"
	docker volume prune
	docker container prune

hint:
	hint http://localhost:3000
