> This repo is under development. Feel free to submit issues and
> pull requests, clone or fork it for your own use, but be prepared
> for some bugs and more importantly fundamental changes in the future.

# gStack

A Docker based full stack Django-Postgres-Nginx project
skeleton to build web applications.

It is built for those who

* creates web apps in Django
* likes (almost) identical development and production environments
* wants production setup to be easy but secure
* has a reasonable knowledge of Docker

# Quick Start for Developers

You will need `Docker`, `Docker Compose` and `make` installed.

1.  Clone the repository

    ```sh
    git clone https://github.com/galaktika-solutions/gStack.git myproject
    cd myproject
    rm -rf .git
    git init
    ```

1.  Configure you project by creating a `.env` file in the project's root directory
    _(The values here are just examples. Go on with it now, but you have to
    change them soon.)_

    ```env
    COMPOSE_FILE=docker-compose.yml:docker-compose.dev.yml
    DEV_MODE=true
    INSECURE_FILES_ALLOWED=true

    COMPOSE_PROJECT_NAME=myproject
    IMAGE_NAME_PREFIX=docker-registry:5000/myproject
    IMAGE_TAG=latest
    NETWORK_SUBNET=10.7.10.0/24

    HOST_NAME=myproject.dev

    # These variables only need at build time
    # Use them in build and development environments
    VERSION=0.1
    VERBOSE_PROJECT_NAME=myProject
    ```

1.  Set up your secrets (see [Secrets](#secrets-the-secrerts-directory))

# Manual

## Configuration (the `.env` file)

This file is in `env` format. Docker Compose will automatically see these
variables, as well as all containers. `make` also reads some of them.
You can freely add configuration to your project by placing variables here,
but it is crucial for these values not to be confidential. _The variables
in the `.env` file will be seen by virtually everybody._

###### `COMPOSE_FILE`

## Secrets (the `.secrets` directory)

## Setup for Production

```sh
docker pull galaktikasolutions/gstack-main
docker run --rm -it -v "$(pwd):/project_root" galaktikasolutions/gstack-main demo_setup
sudo docker-compose up
```

The `run` command with options:

```sh
docker run --rm -it -v "$(pwd):/project_root" \
  -e "HOST_NAME=gstack.dev" \
  -e "NETWORK_SUBNET=10.7.11.0/24" \
  -e "COMPOSE_PROJECT_NAME=gstackdemo" \
  galaktikasolutions/gstack-main demo_setup
```

# Recipes
