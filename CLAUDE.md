# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Collection of independent Docker base images for Symfony/PHP development, one directory per PHP version/variant (php71 … php83-bullseye). There is no application code, test suite, lint, or CI — each directory is a self-contained Docker build context.

## Building Images

Build from inside the variant directory. The tag convention is `micayael/symfony-base:<directory-name>`:

```bash
cd php83-bullseye
docker build -t micayael/symfony-base:php83-bullseye .
```

Each directory's `README.md` contains its exact build command. Exception: `php74-cli` is tagged `micayael/symfony-cli-base:php7.4.10-cli-alpine3.12`.

The `-wk` variants (`php71-wk`, `php72-wk`) only add wkhtmltopdf on top of `FROM micayael/symfony-base:phpXX`, so the corresponding base image must be built first.

## Image Architecture

Two generations of images coexist:

- **Modern** (`php74-apache`, `php74-bullseye`, `php80-bullseye` … `php83-bullseye`): parameterized via ENV vars — `PROJECT_ROOT=/src`, `APACHE_DOCUMENT_ROOT=/src/public`, and (bullseye only) `APACHE_HTTP_PORT=80` — which are referenced by the copied Apache configs (`000-default.conf`, `ports.conf`). They install Composer, symfony-cli, Node.js/yarn, enable `mod_rewrite`, and add the PHP extensions intl, zip, apcu, xsl, opcache, pdo_mysql, pdo_pgsql. Workdir is `/src`.
- **Legacy** (`php71`, `php72`, `php73`): hardcoded Apache config, no ENV parameterization.

The bullseye Dockerfiles start with two `FROM` lines (cli then apache); the apache image is the effective base — the cli line is vestigial.

To add a new PHP version, copy the newest `phpXX-bullseye` directory and update the `FROM` lines, the tag in `README.md`, and Node.js version if needed.

## Running Containers

`bin/docker-run` and `bin/docker-exec` in the bullseye directories are templates with `<CONTAINER_NAME>`/`<IMAGE_NAME>` placeholders, meant to be copied into a Symfony project: `docker-run` mounts the current directory at `/src` and maps host port 9999 to container port 80.

## Conventions

- Commit messages are written in Spanish.
