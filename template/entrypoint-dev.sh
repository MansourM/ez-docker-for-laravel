#!/bin/bash

set -e

cd /var/www

composer install

npm install
npm run build;

php artisan key:generate
php artisan migrate:fresh --seed


supervisord -c /etc/supervisor/supervisord.conf
