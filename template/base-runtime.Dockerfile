# ez-laravel-runtime — the serving half of the runtime pair.
#
# php-fpm + nginx + supervisor, the extensions a Laravel app needs at run time, and this repo's
# nginx/php/supervisor configuration. An app's own Dockerfile copies its built tree in, and the
# environment file is mounted at run time.
#
# www-data keeps its distribution uid/gid so one published image serves every host; aligning
# ownership with a particular host belongs to the layer that knows which host it is for.

ARG PHP_VERSION=8.3
# FULLY QUALIFIED on purpose. Docker resolves a bare `php:...` against an implicit Docker Hub
# default; buildah does not — it resolves bare names through registries.conf.d shortname aliases
# and errors with "no stage or image found with that name". The publish pipeline builds with
# buildah, so a bare name here fails CI while still building locally. Do not shorten it back.
FROM docker.io/library/php:${PHP_VERSION}-fpm

ENV DEBIAN_FRONTEND=noninteractive

ENV USER_NAME=www-data
ARG GROUP_NAME=www-data
ARG WORKDIR=/var/www
ARG TZ=Asia/Tehran

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zlib1g-dev \
    libjpeg-dev\
    libpng-dev\
    libgmp-dev \
    libfreetype6-dev \
    libicu-dev  \
    g++ \
    libzip-dev \
    nginx \
    supervisor \
    default-mysql-client #This is needed because we need `mysqldump` for `spatie/laravel-backup`

# --with-jpeg is REQUIRED, not optional. Since PHP 7.4 gd only gets JPEG support when it is asked
# for explicitly; having libjpeg-dev installed is not enough. Without it the build still succeeds
# and `php --ri gd` simply omits the JPEG line, so imagejpeg()/imagecreatefromjpeg() are missing and
# any JPEG upload fails much later with a confusing error. Measured 2026-09-01: every image this
# recipe has ever produced — 8.3 included — reports gd_info()['JPEG Support'] === false.
# ci/assert-base-images.sh asserts JPEG and PNG so this cannot regress silently again.
# The path form (--with-freetype=/usr/include/) is pre-7.4 syntax; 7.4+ takes a bare flag.
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# NOTE: opcache is compiled into PHP 8.5+, but is a separately-installable shared
# module on 8.2-8.4, so only install it when it isn't already present.
RUN docker-php-ext-install exif pdo pdo_mysql zip gd intl pcntl sockets bcmath \
    && docker-php-ext-enable exif \
    && if ! php -m | grep -qi 'Zend OPcache'; then \
         docker-php-ext-install opcache && docker-php-ext-enable opcache; \
       fi

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -rf /etc/nginx/conf.d/default.conf \
    && rm -rf /etc/nginx/sites-enabled/default \
    && rm -rf /etc/nginx/sites-available/default \
    && rm -rf /etc/nginx/nginx.conf

COPY ./php.ini /usr/local/etc/php/conf.d/php.ini
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY ./supervisord.conf /etc/supervisor/supervisord.conf

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf
COPY ./nginx/security-headers.conf /etc/nginx/conf.d/security-headers.conf

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /var/log/supervisor \
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/cache/nginx \
    && mkdir -p /var/log/php \
    && chmod 755 /var/log/php \
    && mkdir -p /etc/supervisor/conf.d/

RUN chown -R ${USER_NAME}:${GROUP_NAME} /var/log/ && \
  chown -R ${USER_NAME}:${GROUP_NAME} /etc/supervisor/conf.d/ && \
  chown -R ${USER_NAME}:${GROUP_NAME} $PHP_INI_DIR/conf.d/ && \
  chown -R ${USER_NAME}:${GROUP_NAME} /var/log/php && \
  touch /var/run/nginx.pid && \
  chown -R ${USER_NAME}:${GROUP_NAME} /var/cache/nginx && \
  chown -R ${USER_NAME}:${GROUP_NAME} /var/lib/nginx/ && \
  chown -R ${USER_NAME}:${GROUP_NAME} /etc/nginx/nginx.conf && \
  chown -R ${USER_NAME}:${GROUP_NAME} /var/run/nginx.pid && \
  chown -R ${USER_NAME}:${GROUP_NAME} /var/log/supervisor && \
  chown -R ${USER_NAME}:${GROUP_NAME} /etc/nginx/conf.d/

WORKDIR ${WORKDIR}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
