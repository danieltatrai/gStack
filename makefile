SHELL=/bin/bash

timestamp := $(shell date +"%Y-%m-%d-%H-%M")
usr := $(shell id -u):$(shell id -g)
devcompose := COMPOSE_FILE=docker-compose.yml:docker-compose.dev.yml

createsecret:
	@docker-compose run --rm -u $(usr) postgres createsecret

readsecret:
	@docker-compose run --rm -u $(usr) postgres readsecret

build:
	$(devcompose) docker-compose down
	$(devcompose) docker-compose build
	$(devcompose) docker-compose run --rm build_js npm install
	$(devcompose) docker-compose run --rm build_js npm run build
	$(devcompose) docker-compose run --rm django collectstatic
	cp -R js_client/build/ static
	echo -n "$(timestamp)" > conf/VERSION
	$(devcompose) docker-compose build
	$(devcompose) docker-compose down

create_dev_certificates:
	docker-compose run --rm -u $(usr) -w /src/.files postgres ./create_dev_certificates.sh

migrate:
	docker-compose run --rm django with_django django-admin migrate

.PHONY: backup
backup:
	docker-compose run --rm backup backup

restore:
	docker-compose down
	docker-compose run --rm backup restore
