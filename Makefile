APP := app
RUN := docker-compose -f docker-compose.development.yml run --rm $(APP)
env := development
service := app


run:
	$(RUN) $(command)

build:
	docker-compose -f docker-compose.development.yml up --build

build-service:
	docker-compose -f docker-compose.development.yml up -d --no-deps --build $(service)

up:
	docker-compose -f docker-compose.development.yml up

down:
	docker-compose -f docker-compose.development.yml down

remove-volumes:
	docker-compose -f docker-compose.development.yml down -v

db-drop:
	$(RUN) bash -c "rm /var/www/alegreme/db/schema.rb && rake db:drop"

db-create:
	$(RUN) bash -c "rake db:migrate && rake db:seed"

credentials:
	$(RUN) bash -c "EDITOR=vim rails credentials:edit"

prune:
	docker image prune
