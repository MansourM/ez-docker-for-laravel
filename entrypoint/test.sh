#!/bin/bash

php artisan key:generate

php artisan migrate:fresh --seed

php artisan serve --port=8000 --host=0.0.0.0 --env=.env
