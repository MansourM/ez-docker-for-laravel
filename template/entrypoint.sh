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

# Cache at run time, not at build time. An image published to a registry must not carry a .env
# (it would ship APP_KEY and the database password to anyone who can pull it), so the real
# environment only exists here — caching earlier would freeze the wrong values.
#
# Only for the deployed environments. Laravel's caches compile config, routes and views into
# fixed files; dev and test mount live source and expect an edit to take effect, so caching there
# would make changes invisible until the next restart.
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
        # Is a backup tool actually available? Ask artisan, not composer: composer is a build-time
        # tool and is not in the runtime image, so `composer show` here fails whether or not the
        # package is installed — which silently sent every production deploy down the "skip
        # migrations" path below.
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
            # Refuse rather than skip. Skipping leaves new code running against an old schema —
            # the application looks healthy and misbehaves on the paths that needed the migration,
            # which is a worse failure than not starting.
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
