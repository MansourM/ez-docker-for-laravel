#TODO add better logs to laravel commands?
docker compose -f "apps/${args[APP_NAME]}/compose-laravel.yml" --profile "${args[APP_ENV]}" down
