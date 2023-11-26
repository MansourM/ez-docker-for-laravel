#!/bin/bash

#if APP_ENV is not production and APP_DEBUG is true seed database
if [ "$APP_ENV" != "production" ] && [ "$APP_DEBUG" = "true" ]; then
    php artisan migrate:fresh --seed
fi

php artisan serve --port=8000 --host=0.0.0.0 --env=.env
