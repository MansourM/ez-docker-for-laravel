app_dir="apps/${args[APP_NAME]}"
merged_env_path=$(merge_laravel_envs "$app_dir" "${args[APP_ENV]}")
load_laravel_envs "$app_dir" "${args[APP_ENV]}"

if [[ "${args[APP_ENV]}" == "dev" ]]; then
  cp "$merged_env_path" "$app_dir/src-dev/.env"
  chown -R "$OWNER_USER_NAME:$OWNER_GROUP_NAME" "$app_dir/src-dev"
fi

docker compose -f "$app_dir/compose-laravel.yml" --profile "${args[APP_ENV]}" --env-file "$merged_env_path" restart
