#!/bin/bash


#echo "removing existing vendor..."
#rm -rf vendor
#echo "removing existing node_modules..."
#rm -rf node_modules

composer install --optimize-autoloader --no-dev

npm install

#echo "removing existing public/build..."
#rm -rf public/build

echo "building assets..."
npm run production

#echo "clear cache and optimization files..."
#php artisan cache:clear
#php artisan view:clear
#php artisan optimize:clear

echo "generate optimization files..."
php artisan config:cache
php artisan event:cache
php artisan route:cache
php artisan view:cache

php artisan key:generate