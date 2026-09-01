# ez-laravel-build — the build toolchain half of the runtime pair.
#
# Composer + Node + the extensions needed to resolve and compile a Laravel app. An app's own
# Dockerfile starts FROM this, installs its dependencies, and copies the result into
# ez-laravel-runtime.
#
# Published from this repo (see notes/registry-images.md) so every app shares one toolchain.

# Both ARGs are declared in GLOBAL scope (before any FROM) on purpose: `COPY --from=` does not
# expand variables, so the Node version can only be parameterised by naming a stage built from it.
# Without the stage, `COPY --from=...node:${NODE_VERSION}...` fails with
# "variable expansion is not supported for --from".
ARG PHP_VERSION=8.3
ARG NODE_VERSION=22

# FULLY QUALIFIED — see the note in base-runtime.Dockerfile. buildah cannot resolve a bare name.
FROM docker.io/library/node:${NODE_VERSION}-bookworm-slim AS node

# FULLY QUALIFIED — see the note in base-runtime.Dockerfile. buildah cannot resolve a bare name.
FROM docker.io/library/php:${PHP_VERSION}-fpm

ENV DEBIAN_FRONTEND=noninteractive

ARG WORKDIR=/var/www

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libicu-dev \
    g++ \
    libzip-dev

# exif and intl are needed for filament
RUN docker-php-ext-install zip exif intl

# Composer and Node come from their official images rather than piped install scripts —
# fardadev-infra rules.md §7 forbids `curl | bash` installers, and this also drops an apt-repo
# fetch from every build. Debian-to-Debian copy; ci/assert-base-images.sh runs `node -v` / `npm -v`
# / `composer --version` afterwards so a glibc or path mismatch fails the build here instead of
# surfacing as a broken app build months later.
COPY --from=docker.io/library/composer:2 /usr/bin/composer /usr/local/bin/composer
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN set -eux; \
    ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm; \
    ln -sf /usr/local/lib/node_modules/npx/bin/npx-cli.js /usr/local/bin/npx 2>/dev/null \
      || ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx; \
    npm install -g rtlcss; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR ${WORKDIR}
