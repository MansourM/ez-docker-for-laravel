#inspect_args

# Validate application name
if ! validate_app_name "${args[APP_NAME]}"; then
  log_error "Invalid application name: ${args[APP_NAME]}"
  log_error "Application names must:"
  log_error "  - Contain only letters, numbers, hyphens, and underscores"
  log_error "  - Be 64 characters or less"
  log_error "Example: my-laravel-app"
  exit 1
fi

# Validate environment name
if ! validate_environment "${args[APP_ENV]}"; then
  log_error "Invalid environment: ${args[APP_ENV]}"
  log_error "Environment must be one of: dev, test, staging, production"
  exit 1
fi

log_header "Preparing to deploy Laravel in ${args[APP_ENV]} mode"

# Check Docker daemon availability
if ! docker info >/dev/null 2>&1; then
  log_error "Cannot connect to Docker daemon"
  log_error "Please ensure:"
  log_error "  1. Docker is installed and running"
  log_error "  2. Docker service is started: sudo systemctl start docker"
  log_error "  3. Your user has Docker permissions: sudo usermod -aG docker \$USER"
  exit 1
fi

app_dir="apps/${args[APP_NAME]}"
if [[ ! -d "$app_dir" ]]; then
    log_error "Application directory not found: $app_dir"
    log_error "The application '${args[APP_NAME]}' has not been initialized."
    log_error "Please create the application first:"
    log_error "  sudo ./ez laravel new"
    exit 1
fi

merged_env_path=$(merge_laravel_envs "$app_dir" "${args[APP_ENV]}")
load_laravel_envs "$app_dir" "${args[APP_ENV]}"

update_source_code

containers=("nginx-pm" "mysql8")
check_containers "${containers[@]}"

create_new_database_and_user "$DB_DATABASE" "$DB_USERNAME" "$DB_PASSWORD"

if [[ "${args[APP_ENV]}" == "dev" ]]; then
  cp "$merged_env_path" "$app_dir/src-dev/${LARAVEL_ROOT}.env"
  chown -R "$OWNER_USER_NAME:$OWNER_GROUP_NAME" "$app_dir/src-dev"
fi

log_header "Running Docker Compose for Laravel ${args[APP_ENV]}"
docker compose -f "$app_dir/compose-laravel.yml" --profile "${args[APP_ENV]}" --env-file "$merged_env_path" up --build -d

if [ $? -ne 0 ]; then
  log_error "Failed to start Docker containers for ${args[APP_NAME]} (${args[APP_ENV]})"
  log_error "Troubleshooting steps:"
  log_error "  1. Check Docker logs: docker compose -f $app_dir/compose-laravel.yml logs"
  log_error "  2. Verify Docker is running: docker ps"
  log_error "  3. Check for port conflicts: lsof -i :$APP_PORT"
  log_error "  4. Review environment file: $merged_env_path"
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
    log_error "APP_PORT not set for ${args[APP_ENV]} environment"
    log_error "Please add APP_PORT to: apps/${args[APP_NAME]}/env/${args[APP_ENV]}.env"
    log_error "Example: APP_PORT=7000"
    exit 1
  fi
fi
