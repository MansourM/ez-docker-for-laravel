#!/bin/bash

echo "reading and setting environment variables..."
while read -r LINE; do
  if [[ $LINE == *'='* ]] && [[ $LINE != '#'* ]]; then
    ENV_VAR="$(echo $LINE | envsubst)"
    eval "declare $ENV_VAR"
  fi
done < .env

echo "removing existing src folder..."
rm -rf src

echo "cloning repository, rename its folder to src..."
git clone -b $GIT_BRANCH $GIT_URL src

echo "copying .env file to src folder..."
cp .env src/.env

echo "copying entrypoint-builder.sh file to src folder..."
cp entrypoint-builder.sh src/entrypoint-builder.sh

echo "copying entrypoint-laravel.sh file to src folder..."
cp entrypoint-laravel.sh src/entrypoint-laravel.sh

docker compose -f docker-compose-builder.yml up --build
docker compose -f docker-compose-common.yml up --build -d

read -n1 -r -p "Press any key to continue..." key
