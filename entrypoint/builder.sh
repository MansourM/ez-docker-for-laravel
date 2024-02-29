#!/bin/bash

chown -R ${USER_NAME}:${GROUP_NAME} /usr/src

npm install

#im not sure about this :)
npm audit fix

if [[ "${APP_ENV}" == "test" ]]; then
  composer install --optimize-autoloader
  npm run build
else # staging or production
  composer install --optimize-autoloader --no-dev
  npm run production
fi
