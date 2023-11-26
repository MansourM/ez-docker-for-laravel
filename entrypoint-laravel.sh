#!/bin/bash

if [[ "$APP_ENV" == "dev" || "$APP_ENV" == "staging" ]]; then
    php artisan migrate:fresh --seed
else
    php artisan migrate
fi

php artisan serve --port=8000 --host=0.0.0.0 --env=.env
