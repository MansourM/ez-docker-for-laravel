inspect_args
log_header "Preparing to deploy Laravel in ${args[APP_ENV]} mode"

app_dir="apps/${args[APP_NAME]}"
if [[ ! -d "$app_dir" ]]; then
    log_error "Directory $app_dir does not exist! you need to setup your app first, try './ez laravel new'"
    exit 1
fi

merged_env_path=$(merge_laravel_envs "$app_dir" "${args[APP_ENV]}")
load_laravel_envs "$app_dir" "${args[APP_ENV]}"

update_source_code

containers=("nginx-pm" "mysql8")
check_containers "${containers[@]}"

create_new_database_and_user "$DB_DATABASE" "$DB_USERNAME" "$DB_PASSWORD"

if [[ "${args[APP_ENV]}" == "dev" ]]; then
  cp "$merged_env_path" "$app_dir/src-dev/.env"
  chown -R "$OWNER_USER_NAME:$OWNER_GROUP_NAME" "$app_dir/src-dev"
fi

log_header "Running Docker Compose for Laravel ${args[APP_ENV]}"
docker compose -f "$app_dir/compose-laravel.yml" --profile "${args[APP_ENV]}" --env-file "$merged_env_path" up --build -d

if [ $? -ne 0 ]; then
  log_error "Docker Compose up failed for app: ${args[APP_NAME]}, environment: ${args[APP_ENV]}"
  exit 1
fi

if [[ "${args[APP_ENV]}" != "dev" ]]; then
  chown -R "$OWNER_USER_NAME:$OWNER_GROUP_NAME" "$app_dir/storage-${args[APP_ENV]}"
fi

log_success "Server running on [${args[APP_NAME]}_${args[APP_ENV]}] container with 'inner' port 80."
log_info "You can connect your website to a domain using Nginx Proxy Manager at [<your_ip>:$PORT_NGINX_PM]."

if [[ "${args[APP_ENV]}" == "dev" || "${args[APP_ENV]}" == "test" ]]; then
  if [[ -n "$APP_PORT" ]]; then
    log_success "Server running on [http://<your_ip>:$APP_PORT]."
  else
  log_warning "APP_PORT not set for test environment. Set it in 'apps/${args[APP_NAME]}/env/test.env'."
  fi
fi
