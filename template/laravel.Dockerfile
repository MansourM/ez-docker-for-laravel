# === Stage 1: Builder ===
FROM php:8.2-fpm AS builder

ENV DEBIAN_FRONTEND noninteractive

ARG APP_ENV
ARG WORKDIR=/var/www
ARG NODE_VERSION=20

# Install required librairies
RUN apt-get update && apt-get install -y \
    git \
    gnupg \
    unzip \
    libicu-dev \
    g++ \
    libzip-dev

RUN docker-php-ext-install zip

RUN curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update

RUN apt-get install -y nodejs \
    && npm install -g npm \
    && npm install -g rtlcss \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR ${WORKDIR}

#TODO use workdir relative pathing to shorten the path
COPY ./entrypoint.sh ${WORKDIR}/entrypoint.sh
RUN chmod +x ${WORKDIR}/entrypoint.sh

COPY ./src-${APP_ENV}/package.json ${WORKDIR}
COPY ./src-${APP_ENV}/package-lock.json ${WORKDIR}

RUN npm install
#TODO, Review if this line should exist here
RUN npm audit fix

COPY ./src-${APP_ENV}/composer.json ${WORKDIR}
COPY ./src-${APP_ENV}/composer.lock ${WORKDIR}

RUN if [ "${APP_ENV}" = "test" ]; then \
      composer install  --no-scripts --no-autoloader; \
    else \
      composer install  --no-scripts --no-autoloader --no-dev; \
    fi

COPY ./src-${APP_ENV} ${WORKDIR}
COPY ./env/generated/${APP_ENV}.env ${WORKDIR}/.env

RUN if [ "${APP_ENV}" = "test" ]; then \
      composer install --optimize-autoloader; \
    else \
      composer install --optimize-autoloader --no-dev; \
    fi

RUN npm run build;


# === Stage 2: Final Image ===
FROM php:8.2-fpm

ENV DEBIAN_FRONTEND noninteractive

ARG OWNER_USER_ID
ARG OWNER_GROUP_ID

ENV USER_NAME=www-data
ARG GROUP_NAME=www-data

ARG WORKDIR=/var/www
ARG TZ=Asia/Tehran

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required librairies
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

# Configure PHP extensions
RUN docker-php-ext-configure gd --with-freetype=/usr/include/

# Install PHP extensions
# RUN pecl install -o -f redis &&  rm -rf /tmp/pear &&  docker-php-ext-enable redis
RUN docker-php-ext-install pdo pdo_mysql zip gd intl pcntl opcache sockets bcmath \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-enable opcache

#Clean apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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

RUN usermod -u ${OWNER_USER_ID} ${USER_NAME} \
    && groupmod -g ${OWNER_GROUP_ID} ${GROUP_NAME}

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

# Copy files from the builder stage
COPY --from=builder --chown=$USER_NAME:$GROUP_NAME /var/www /var/www

WORKDIR ${WORKDIR}

# Generate Laravel key and cache configurations
RUN php artisan key:generate \
    && php artisan config:cache \
    && php artisan event:cache \
    && php artisan route:cache \
    && php artisan view:cache
