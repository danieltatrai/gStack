# gStack

A Docker based Django-Postgres-Nginx boilerplate.

## What is this?

`gStack` is a boilerplate project that can be used to set up a
Django project stack prepared for a single-host deployment. It uses Docker
to manage software installation and version management. Features that `gStack`
focuses on includes:

* Pushing versioned images to a docker registry
* Handling secrets in a portable way (can be used with Swarm and Kubernetes)
* Separating development and production environment in a clean way, so that
  live deployment is secure by default
* Preconfigured backup and restore processes
* Logging configuration that works well with log shipping solutions

## Before you start

Using a boilerplate to start a project a enables you to start quickly and
focus on business requirements instead of infrastructural details. On the
other hand it is crucial to understand the risks and downsides:

* Update is hard. When you start a project based on a template, you clone
  clone it and start adding code to it. Changes made to the original repo
  can not be merged in to the one you are working on. Even if you could, modified
  settings, some extra code you put here and there would most probably break
  such a merge. We might find a more robust solution for this problem in the
  future but until then it is something you have to accept. Here we list
  some concepts to deal with this particular problem:
  * **Hooks.** We lock down core parts of the template and add places
    where customization can be done. We provide hooks to call custom code.
    Updates only modify core files and folders and guarantee backward compatibility
    on a certain level.
  * **Tooling.** The Create React App way. This is an additional layer over hooks,
    where the core part is packed in some way and hidden from the user.
  * **Codemods.** Each update comes with a tool (probably a script) that
    modifies the existing project. An assumption on the validity of the project
    to update must be made. If it was completely reorganized, the scrip won't
    be able to identify certain parts to modify.
  * **Documenting.** This is a requirement anyway and clearly a prerequisite to
    a codemod solution.
* Becomes too complex easily.
* Hides complexity.
* Solves problems of a certain group of people. Your problems might be very different
  soon.

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
