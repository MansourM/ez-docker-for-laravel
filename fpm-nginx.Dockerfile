FROM php:8.2-fpm

ARG APP_ENV
ENV TZ=Asia/Tehran
ENV DEBIAN_FRONTEND noninteractive

ARG USER_ID=1000
ENV USER_NAME=www-data

ARG GROUP_ID=1000
ARG GROUP_NAME=www-data

ARG WORKDIR=/var/www

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required librairies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zlib1g-dev \
    libjpeg-dev\
    libpng-dev\
    libfreetype6-dev \
    libpq-dev \
    libicu-dev g++ \
    libzip-dev

# Configure PHP extensions
RUN docker-php-ext-configure gd --with-freetype=/usr/include/

# Install PHP extensions
RUN pecl install -o -f redis &&  rm -rf /tmp/pear &&  docker-php-ext-enable redis
RUN docker-php-ext-install pdo pdo_mysql zip gd intl pcntl opcache
RUN docker-php-ext-configure pcntl --enable-pcntl
RUN docker-php-ext-enable opcache
RUN docker-php-ext-install sockets
RUN docker-php-ext-install bcmath
RUN apt install -y libgmp-dev

# Install nginx
RUN apt-get update && apt-get install -y nginx

#Clean apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Remove Default nginx cof
RUN rm -rf /etc/nginx/conf.d/default.conf \
    && rm -rf /etc/nginx/sites-enabled/default \
    && rm -rf /etc/nginx/sites-available/default \
    && rm -rf /etc/nginx/nginx.conf

COPY config/php.ini /usr/local/etc/php/conf.d/
COPY config/opcache.ini /usr/local/etc/php/conf.d/
COPY config/supervisord.conf /etc/supervisor/supervisord.conf

COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/default.conf /etc/nginx/conf.d/default.conf


RUN usermod -u ${USER_ID} ${USER_NAME}
RUN groupmod -g ${USER_ID} ${GROUP_NAME}

RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/log/nginx
RUN mkdir -p /var/cache/nginx
RUN mkdir -p /etc/supervisor/conf.d/

RUN chown -R ${USER_NAME}:${GROUP_NAME} /var/www && \
  chown -R ${USER_NAME}:${GROUP_NAME} /var/log/ && \
  chown -R ${USER_NAME}:${GROUP_NAME} /etc/supervisor/conf.d/ && \
  chown -R ${USER_NAME}:${GROUP_NAME} $PHP_INI_DIR/conf.d/ && \
  touch /var/run/nginx.pid && \
  chown -R $USER_NAME:$USER_NAME /var/cache/nginx && \
  chown -R $USER_NAME:$USER_NAME /var/lib/nginx/ && \
  chown -R $USER_NAME:$USER_NAME /etc/nginx/nginx.conf && \
  chown -R $USER_NAME:$USER_NAME /var/run/nginx.pid && \
  chown -R $USER_NAME:$USER_NAME /var/log/supervisor && \
  chown -R $USER_NAME:$USER_NAME /etc/nginx/conf.d/ && \
  chown -R ${USER_NAME}:${GROUP_NAME} /tmp

#careful with laravel path, it must be the same as the one in the src/laravel_deploy_command.sh
COPY ./laravel-${APP_ENV} ${WORKDIR}

WORKDIR ${WORKDIR}

# Generate Laravel key and cache configurations
RUN php artisan key:generate \
    && php artisan config:cache \
    && php artisan event:cache \
    && php artisan route:cache \
    && php artisan view:cache

#CMD ["supervisord", "-n"]
