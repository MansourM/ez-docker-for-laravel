# ez-laravel-build — the build toolchain half of the runtime pair.
#
# Composer + Node + the extensions needed to resolve and compile a Laravel app. Carries no
# application code: an app's own Dockerfile starts FROM this, installs its dependencies, and
# copies the result into ez-laravel-runtime.
#
# Built and published from this repo (see notes/registry-images.md), so every app shares one
# toolchain instead of each repeating ~50 lines of it.

ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm

ENV DEBIAN_FRONTEND=noninteractive

ARG NODE_VERSION=20
ARG WORKDIR=/var/www

RUN apt-get update && apt-get install -y \
    git \
    gnupg \
    unzip \
    libicu-dev \
    g++ \
    libzip-dev

# exif and intl are needed for filament
RUN docker-php-ext-install zip exif intl

RUN curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update

RUN apt-get install -y nodejs \
    && npm install -g npm \
    && npm install -g rtlcss \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR ${WORKDIR}
