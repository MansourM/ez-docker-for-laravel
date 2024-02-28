#!/bin/bash

composer install --optimize-autoloader

npm install

#im not sure about this :)
#npm audit fix

echo "building assets..."
npm run build
