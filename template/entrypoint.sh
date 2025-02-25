#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

app_env=${APP_ENV}

if [ -z "$app_env" ]; then
    echo "Error: APP_ENV is not set."
    exit 1
fi

# Generate Laravel key if it doesn't exist
if [ -z "$(grep '^APP_KEY=' .env)" ]; then
    echo "Generating Laravel application key..."
    php artisan key:generate
fi

case "$app_env" in
    "local" | "dev" | "test")
        echo "fresh database + seed ..."
        php artisan migrate:fresh --seed
        ;;
    "staging")
        echo "migrating database in staging --force..."
        php artisan migrate --force
        ;;
    "production")
        if composer show spatie/laravel-backup > /dev/null 2>&1; then
            echo "Backing up database..."
            php artisan backup:run --only-db

            echo "Migrating database in production..."
            php artisan migrate --force
        else
            echo "Error: spatie/laravel-backup is not installed. Skipping migrations."
            echo "Please handle migrations manually after ensuring a backup is available."
            exit 1
        fi
        ;;
    *)
        echo "Unknown environment: $app_env"
        exit 1
        ;;
esac

supervisord -c /etc/supervisor/supervisord.conf
