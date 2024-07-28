# === Stage 1: Builder ===
FROM php:8.2-fpm AS builder

ENV DEBIAN_FRONTEND noninteractive

ARG NODE_VERSION=20

ARG USER_ID=1000
ENV USER_NAME=www-data

ARG GROUP_ID=1000
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
# RUN pecl install -o -f redis &&  rm -rf /tmp/pear &&  docker-php-ext-enable redis
RUN docker-php-ext-install pdo pdo_mysql zip gd intl pcntl opcache sockets bcmath \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-enable opcache


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

RUN usermod -u ${USER_ID} ${USER_NAME} \
    && groupmod -g ${USER_ID} ${GROUP_NAME}

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


COPY ./entrypoint-dev.sh /usr/local/bin/entrypoint-dev.sh

RUN chmod +x /usr/local/bin/start-container

ENTRYPOINT ["entrypoint-dev.sh"]
