#!/bin/bash

if [ ! -f ".env" ]; then
    echo ".env file doesn't exists!!"
fi

php artisan migrate --seed

php artisan serve --port=80 --host=0.0.0.0 --env=.env
