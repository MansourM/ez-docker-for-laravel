#!/bin/bash

composer install --optimize-autoloader --no-dev

npm install

#im not sure about this :)
npm audit fix

#echo "removing existing public/build..."
#rm -rf public/build

echo "building assets..."
npm run production
