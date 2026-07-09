# PHP version (supported: 8.2, 8.3, 8.4, 8.5). Passed as a build arg from the
# app's env; defaults to 8.3 so pre-existing apps rebuild unchanged.
ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm

ENV DEBIAN_FRONTEND noninteractive

ARG NODE_VERSION=20

ARG OWNER_USER_ID
ARG OWNER_GROUP_ID

ENV USER_NAME=www-data
ARG GROUP_NAME=www-data

ARG TZ=Asia/Tehran
ARG WORKDIR=/var/www

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required librairies
RUN apt-get update && apt-get install -y \
    git \
    gnupg \
    unzip \
    libicu-dev \
    g++ \
    libzip-dev \
    zlib1g-dev \
    libjpeg-dev\
    libpng-dev\
    libgmp-dev \
    libfreetype6-dev \
    nginx \
    supervisor \
    default-mysql-client

# Configure PHP extensions
RUN docker-php-ext-configure gd --with-freetype=/usr/include/

# Install PHP extensions
# NOTE: opcache is compiled into PHP 8.5+, but is a separately-installable shared
# module on 8.2-8.4, so only install it when it isn't already present.
# RUN pecl install -o -f redis &&  rm -rf /tmp/pear &&  docker-php-ext-enable redis
RUN docker-php-ext-install exif pdo pdo_mysql zip gd intl pcntl sockets bcmath \
    && docker-php-ext-enable exif \
    && if ! php -m | grep -qi 'Zend OPcache'; then \
         docker-php-ext-install opcache && docker-php-ext-enable opcache; \
       fi


RUN curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update

RUN apt-get install -y nodejs \
    && npm install -g npm \
    && npm install -g rtlcss \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Remove Default nginx cof
RUN rm -rf /etc/nginx/conf.d/default.conf \
    && rm -rf /etc/nginx/sites-enabled/default \
    && rm -rf /etc/nginx/sites-available/default \
    && rm -rf /etc/nginx/nginx.conf

COPY ./php.ini /usr/local/etc/php/conf.d/php.ini
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY ./supervisord.conf /etc/supervisor/supervisord.conf

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy entrypoint for dev environment
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN if [ $(id -u www-data) -ne 0 ]; then usermod -u ${OWNER_USER_ID} www-data; fi \
    && if [ $(getent group www-data | cut -d: -f3) -ne 0 ]; then groupmod -g ${OWNER_GROUP_ID} www-data; fi


RUN mkdir -p /var/log/supervisor \
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/cache/nginx \
    && mkdir -p /etc/supervisor/conf.d/

RUN chown -R ${USER_NAME}:${GROUP_NAME} /var/log/ && \
  chown -R ${USER_NAME}:${GROUP_NAME} /etc/supervisor/conf.d/ && \
  chown -R ${USER_NAME}:${GROUP_NAME} $PHP_INI_DIR/conf.d/ && \
  touch /var/run/nginx.pid && \
  chown -R $USER_NAME:$GROUP_NAME /var/cache/nginx && \
  chown -R $USER_NAME:$GROUP_NAME /var/lib/nginx/ && \
  chown -R $USER_NAME:$GROUP_NAME /etc/nginx/nginx.conf && \
  chown -R $USER_NAME:$GROUP_NAME /var/run/nginx.pid && \
  chown -R $USER_NAME:$GROUP_NAME /var/log/supervisor && \
  chown -R $USER_NAME:$GROUP_NAME /etc/nginx/conf.d/

WORKDIR ${WORKDIR}
