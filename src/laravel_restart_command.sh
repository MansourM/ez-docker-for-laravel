app_dir="apps/${args[APP_NAME]}"
merged_env_path=$(load_laravel_envs "$app_dir" "${args[APP_ENV]}")

docker compose -f "apps/${args[APP_NAME]}/compose-laravel.yml" --profile "${args[APP_ENV]}" --env-file "$merged_env_path" restart
