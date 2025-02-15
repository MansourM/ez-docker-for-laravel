#!/bin/bash

set -e

cd /var/www

composer install

npm install
npm run build;

php artisan key:generate
php artisan migrate --force
php artisan migrate:fresh --seed
php artisan optimize:clear

#add these or other similar ones here if needed
#php artisan optimize
#php artisan filament:optimize
#php artisan shield:generate --all --panel admin

supervisord -c /etc/supervisor/supervisord.conf
