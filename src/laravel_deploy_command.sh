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

DEPLOY_MODE="${DEPLOY_MODE:-build}"

if [[ "$DEPLOY_MODE" != "build" && "$DEPLOY_MODE" != "image" ]]; then
  log_error "Invalid DEPLOY_MODE: '$DEPLOY_MODE' (expected 'build' or 'image')"
  log_error "Set it in apps/${args[APP_NAME]}/env/app.env; omit it to keep building on this host."
  exit 1
fi

if [[ "$DEPLOY_MODE" == "image" ]]; then
  # The image already contains the application, so this host needs no source, build toolchain or
  # private-package credentials; CI held those when it built it.
  if [[ "${args[APP_ENV]}" == "dev" || "${args[APP_ENV]}" == "test" ]]; then
    log_error "DEPLOY_MODE=image does not apply to ${args[APP_ENV]}."
    log_error "dev mounts live source and test builds the tree it is testing; neither runs a fixed artifact."
    exit 1
  fi
  if [[ -z "$APP_IMAGE" ]]; then
    log_error "DEPLOY_MODE=image but APP_IMAGE is empty."
    log_error "Set APP_IMAGE to the full image reference, e.g."
    log_error "  APP_IMAGE=registry.example.com/group/app:<tag>"
    exit 1
  fi
  # Naming the missing template beats docker compose's own error for a missing file.
  if [[ ! -f "$app_dir/compose-laravel-image.yml" ]]; then
    log_error "DEPLOY_MODE=image but $app_dir/compose-laravel-image.yml is missing."
    log_error "This app predates image mode. Copy the template in:"
    log_error "  cp template/compose-laravel-image.yml $app_dir/"
    log_error "  cp template/common-laravel.yml $app_dir/"
    exit 1
  fi
  log_info "Image mode — deploying $APP_IMAGE (no source checkout, no build on this host)."
else
  update_source_code
fi

containers=("nginx-pm" "mysql8")
check_containers "${containers[@]}"

create_new_database_and_user "$DB_DATABASE" "$DB_USERNAME" "$DB_PASSWORD"

if [[ "${args[APP_ENV]}" == "dev" ]]; then
  cp "$merged_env_path" "$app_dir/src-dev/${LARAVEL_ROOT}.env"
  chown -R "$OWNER_USER_NAME:$OWNER_GROUP_NAME" "$app_dir/src-dev"
fi

log_header "Running Docker Compose for Laravel ${args[APP_ENV]}"
if [[ "$DEPLOY_MODE" == "image" ]]; then
  registry_login "$REGISTRY_HOST" "$REGISTRY_USER" "$REGISTRY_TOKEN"

  # The published runtime keeps www-data at its distribution uid so one image serves every host,
  # so the mounted storage has to match the container rather than the host user. It runs before
  # the container starts because the entrypoint writes logs and caches on its first breath.
  storage_dir="$app_dir/storage-${args[APP_ENV]}"
  mkdir -p "$storage_dir/volume" "$storage_dir/logs"
  chown -R "${IMAGE_USER_ID:-33}:${IMAGE_GROUP_ID:-33}" "$storage_dir"
  compose_file="$app_dir/compose-laravel-image.yml"
  # Pull first so a registry or tag problem fails before the running container is touched.
  docker compose -f "$compose_file" --profile "${args[APP_ENV]}" --env-file "$merged_env_path" pull \
    && docker compose -f "$compose_file" --profile "${args[APP_ENV]}" --env-file "$merged_env_path" up -d
else
  docker compose -f "$app_dir/compose-laravel.yml" --profile "${args[APP_ENV]}" --env-file "$merged_env_path" up --build -d
fi

if [ $? -ne 0 ]; then
  log_error "Failed to start Docker containers for ${args[APP_NAME]} (${args[APP_ENV]})"
  log_error "Troubleshooting steps:"
  log_error "  1. Check Docker logs: docker compose -f $app_dir/compose-laravel.yml logs"
  log_error "  2. Verify Docker is running: docker ps"
  log_error "  3. Check for port conflicts: lsof -i :$APP_PORT"
  log_error "  4. Review environment file: $merged_env_path"
  exit 1
fi

if [[ "${args[APP_ENV]}" != "dev" && "$DEPLOY_MODE" != "image" ]]; then
  # Build mode remaps www-data to OWNER_USER_ID, making the host owner and the container the same
  # uid. Image mode has already matched the container's uid above.
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
