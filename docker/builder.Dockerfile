FROM ubuntu:22.04

ARG NODE_VERSION=20
ENV DEBIAN_FRONTEND noninteractive

ARG USER_ID=1000
ENV USER_NAME=www-data

ARG GROUP_ID=1000
ENV GROUP_NAME=www-data


RUN apt-get update \
    && mkdir -p /etc/apt/keyrings \
    && apt-get install -y gnupg curl zip unzip git \
    && curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c' | gpg --dearmor | tee /etc/apt/keyrings/ppa_ondrej_php.gpg > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update

RUN apt-get install -y php8.3-cli php8.3-xml php8.3-curl php8.3-mysql php8.3-mbstring

RUN curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update

RUN apt-get install -y nodejs \
    && npm install -g npm \
    && npm install -g rtlcss


RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN usermod -u ${USER_ID} ${USER_NAME} \
    && groupmod -g ${USER_ID} ${GROUP_NAME}

