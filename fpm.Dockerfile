FROM php:8.2-fpm

ARG APP_ENV
ENV TZ=Asia/Tehran
ENV DEBIAN_FRONTEND noninteractive

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

#RUN apt-get install -y php8.3-cli php8.3-xml php8.3-curl php8.3-mysql php8.3-mbstring php8.3-zip

# Import custom php.ini
##COPY ./php.ini /usr/local/etc/php/
#COPY ./config/php.ini /usr/local/etc/php/

# Copy opcache configration
#COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Install supervisor + Copy Config
#RUN apt-get update && apt-get install -y --no-install-recommends supervisor
#COPY ./supervisor/supervisord.conf /etc/supervisord.conf
#COPY ./supervisor/supervisor.d /etc/supervisor/conf.d/

RUN usermod -u 1000 www-data

#Clean apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#careful with laravel path, it must be the same as the one in the src/laravel_deploy_command.sh
COPY ./laravel-${APP_ENV} /var/www

WORKDIR /var/www

# Generate Laravel key and cache configurations
RUN php artisan key:generate \
    && php artisan config:cache \
    && php artisan event:cache \
    && php artisan route:cache \
    && php artisan view:cache

#CMD ["supervisord", "-n"]
