#!/bin/bash

app_env=${APP_ENV}
if [[ "$app_env" == "dev" || "$app_env" == "staging" ]]; then
    echo "fresh database + seed ..."
    php artisan migrate:fresh --seed
else
  echo "migrating database..."
    php artisan migrate
fi

php artisan serve --port=8000 --host=0.0.0.0 --env=.env
