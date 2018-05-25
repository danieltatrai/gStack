> This repo is under development. Feel free to submit issues and
> pull requests, clone or fork it for your own use, but be prepared
> for some bugs and more importantly fundamental changes in the future.

# gStack

A Docker based Django-Postgres-Nginx boilerplate.

## What is this?

`gStack` is a boilerplate project that can be used to set up a
Django project stack that uses Docker for a single-host deployment.
We could call it a _framework of frameworks_ or a _metaframework_. Features that `gStack` focuses on includes:

* Pushing versioned images to a docker registry (version management)
* Handling secrets in a portable way (can be used with Swarm and Kubernetes)
* Separating development and production environment in a clean way, so that
  live deployment is secure by default
* Preconfigured backup and restore processes
* Logging configuration that works well with log shipping solutions (TODO)
* Simple and secure-by-default demo mode

## Before you start (an optimistic disclaimer)

Using a boilerplate to bootstrap your project enables you to start quickly and
focus on business requirements instead of infrastructural details. On the
other hand it is crucial to understand the risks and downsides:

* **Update is hard**. When you start a project based on a template, you
  clone it and start adding code to it. Changes made to the original repo
  can not be merged in to the one you are working on. Even if you could, modified
  settings, some extra code you put here and there would most probably break
  such a merge. The best we can do here is **providing detailed update instructions**.
* **Becomes too complex easily**. This means that adding your extra features based on existing ones can easily break things or even worse, compromise security. We already know of some additions what _we_ needed for specific projects and _we_ think _you_ will also want to tweek around with. **For these cases we created the recipes section.** If you can not find your use case here, submitting an issue might help.
* **Solves problems of a certain group of people**. Your problems might be very different soon. If these problems are not something that can be handled by adding a recipe and we can not help in and issue, unfortunatelly you are on your own. Good candidate for some **investigation** and a **fork**.

## Setup

### Development

* Clone the repo, change upstream (from now on, it is a new project)
* Modify `.env` (see below)
* Add secrets (see below)
* Start working
* `make push` when ready

### Production

* Create `.env` with appropriate values
* Add the compose file (`docker-compose.yml`)
* Add secrets
* `docker-compose pull`, `docker-compose up`

## `.env`

See below the list of configuration items provided to `docker-compose` and
all container as environment variables.

###### `COMPOSE_FILE`

This key is used only by `docker-compose`.

* In development set it to `docker-compose.yml:docker-compose.dev.yml` (the default)
* In production set to `docker-compose.yml`, or delete it at all.

## Secrets (the `.secrets` directory)

The secrets

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
