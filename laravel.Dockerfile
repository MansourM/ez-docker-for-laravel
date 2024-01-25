FROM ubuntu:22.04

ARG APP_ENV
ENV TZ=Asia/Tehran
ENV DEBIAN_FRONTEND noninteractive

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && mkdir -p /etc/apt/keyrings \
    && apt-get install -y gnupg curl \
    && curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c' | gpg --dearmor | tee /etc/apt/keyrings/ppa_ondrej_php.gpg > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update

RUN apt-get install -y php8.3-cli php8.3-xml php8.3-curl php8.3-mysql php8.3-mbstring php8.3-zip

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#careful with laravel path, it must be the same as the one in the src/laravel_deploy_command.sh
COPY ./laravel-${APP_ENV} /usr/src

COPY ./config/99-php.ini /etc/php/8.3/cli/conf.d/99-php.ini

WORKDIR /usr/src

RUN php artisan key:generate

RUN php artisan config:cache
RUN php artisan event:cache
RUN php artisan route:cache
RUN php artisan view:cache
