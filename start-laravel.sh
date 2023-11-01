#!/bin/bash

docker compose -f docker-compose-laravel.yml up --build

read -n1 -r -p "Press any key to continue..." key
