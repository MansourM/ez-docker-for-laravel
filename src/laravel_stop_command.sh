docker compose -f "apps/${args[APP_NAME]}/compose-laravel.yml" --profile "${args[APP_ENV]}" stop
