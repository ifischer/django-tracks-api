# Convert .env-file to makefile format and export all variables,
# so they are accessible within make and also docker compose
$(shell sed 's/=/ ?= /' .env > /tmp/.make_env)
include /tmp/.make_env
export

HOST_UID = $(shell id -u)
HOST_GID = $(shell id -g)

DOCKER_VOLUMES = -v $(PWD):/app -v $(MUSIC_DIR):/media/music -v images:/media/images -v /app/static -v /app/tests/fixtures/music
DOCKER_ENV = -e DJANGO_SETTINGS_MODULE=tracks_site.settings
DOCKER_PORTS = -p $(DJANGO_TRACKS_API_PORT):8000
DOCKER_WO_PORTS = docker run --user $(UID):$(GID) $(DOCKER_VOLUMES) -it --rm $(DOCKER_ENV) $(DOCKER_NAME)
DOCKER_W_PORTS  = docker run --user $(UID):$(GID) $(DOCKER_VOLUMES) -it --rm $(DOCKER_ENV) $(DOCKER_PORTS) $(DOCKER_NAME)

TRACKS_DB = db/tracks.sqlite

build:
	docker build -t $(DOCKER_NAME) .

clean:
	find . \! -user $(USER) -exec sudo chown $(USER) {} \;
	-docker stop $(DOCKER_NAME)
	-docker rm $(DOCKER_NAME)
	rm -rf $(TRACKS_DB) .venv build dist django_tracks.egg-info
	-rm tracks_api/migrations/0*.py

shell:
	$(DOCKER_WO_PORTS) bash

test:
	$(DOCKER_WO_PORTS) pytest

lint:
	$(DOCKER_WO_PORTS) flake8

mypy:
	$(DOCKER_WO_PORTS) pytest --mypy

virtualenv-create:
	python3.7 -m venv $(VIRTUALENV_DIR)
	. $(VIRTUALENV_DIR)/bin/activate && \
		pip install -r requirements.txt && \
        pip install -r requirements-dev.txt && \
        pip install .
	@echo "Activate virtualenv:\n. $(VIRTUALENV_DIR)/bin/activate"

import:
	$(DOCKER_WO_PORTS) python manage.py import /media/music

migrate:
	$(DOCKER_WO_PORTS) python manage.py makemigrations
	$(DOCKER_WO_PORTS) python manage.py migrate
	$(DOCKER_WO_PORTS) python manage.py create_adminuser

runserver:
	$(DOCKER_W_PORTS) python manage.py runserver 0.0.0.0:8000

django-shell:
	$(DOCKER_WO_PORTS) python manage.py shell_plus

sqlite:
	$(DOCKER_WO_PORTS) sqlite3 $(TRACKS_DB)
