#!/bin/bash

app_env=${APP_ENV}

npm install

#im not sure about this :)
npm audit fix

if [[ "$app_env" == "test" ]]; then
  composer install --optimize-autoloader
  npm run build
else # staging or production
  composer install --optimize-autoloader --no-dev
  npm run production
fi
