#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Running entrypoint.sh"

app_env=${APP_ENV}

if [ -z "$app_env" ]; then
    echo "Error: APP_ENV is not set!"
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    exit 1
fi

# Generate Laravel key if it doesn't exist or is empty
if ! grep -q "^APP_KEY=[^[:space:]]" .env; then
    echo "Generating Laravel application key..."
    php artisan key:generate
    php artisan config:clear
fi

# A registry-published image must stay free of secrets, so the real .env only arrives at run time
# and the caches have to be built here to see it.
#
# Deployed environments only: these caches compile config, routes and views into fixed files, while
# dev and test mount live source and expect an edit to take effect immediately.
case "$app_env" in
    "staging" | "production")
        echo "Caching configuration..."
        php artisan config:cache
        php artisan event:cache
        php artisan route:cache
        php artisan view:cache
        ;;
esac

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
        # artisan is the only package inventory available at run time; composer is a build-time
        # tool and absent from the runtime image, so probing with it reports nothing installed.
        if php artisan list --raw 2>/dev/null | grep -q '^backup:run'; then
          echo "Backing up database..."
          php artisan backup:run --only-db || {
              echo "Error: Database backup failed. Aborting migrations for safety."
              exit 1
          }
          echo "Migrating database in production..."
          php artisan migrate --force
        elif [ "${MIGRATE_WITHOUT_BACKUP}" = "true" ]; then
          echo "WARNING: no backup tool available; MIGRATE_WITHOUT_BACKUP=true, so migrating anyway."
          echo "WARNING: this assumes a database dump was taken outside the container."
          php artisan migrate --force
        else
            # Refusing keeps the failure visible. A skipped migration starts new code on an old
            # schema, where the app looks healthy and misbehaves only where the migration mattered.
            echo "Error: no backup tool available (spatie/laravel-backup provides backup:run)."
            echo "Refusing to migrate without one. Either install it, or take a dump yourself and"
            echo "set MIGRATE_WITHOUT_BACKUP=true for this deploy."
            exit 1
        fi

        # Run a basic health check
        echo "Performing health check..."
        php artisan --version || echo "Warning: Health check did not pass, but continuing anyway"
        ;;
    *)
        echo "Unknown environment: $app_env"
        exit 1
        ;;
esac

# Clear any excess files from previous deployments
echo "Cleaning up..."
php artisan cache:clear

echo "Starting supervisor..."
supervisord -c /etc/supervisor/supervisord.conf
