DOCKER_ENV_PATH="docker/docker.env"

if [[ -f "$DOCKER_ENV_PATH" ]]; then
  load_env "$DOCKER_ENV_PATH"
else
  log_warning "$DOCKER_ENV_PATH not found."
  log_info "Creating new '$DOCKER_ENV_PATH' file."

  PORT_NGINX_PM=$(ask_question "Enter the Nginx Proxy Manager port" "7000")
  PORT_PMA=$(ask_question "Enter the PhpMyAdmin port" "7001")
  GENERATED_PASSWORD=$(generate_password 24)
  DB_ROOT_PASSWORD=$(ask_question "Enter the database root password" "$GENERATED_PASSWORD" )
  SHARED_NETWORK_NAME=$(ask_question "Enter the docker network name" "ez-shared-network")

  create_docker_env
fi

# Check if the network already exists
if docker network inspect "$SHARED_NETWORK_NAME" >/dev/null 2>&1; then
  log "Network '$SHARED_NETWORK_NAME' already exists"
else
  docker network create "$SHARED_NETWORK_NAME"
  if [ $? -eq 0 ]; then
    log_success "Network '$SHARED_NETWORK_NAME' created"
  else
    log_error "Failed to create network '$SHARED_NETWORK_NAME'"
    exit 1
  fi
fi

log_header "Running Docker Compose for shared services"

docker compose -f docker/compose-shared.yml --env-file "docker/docker.env" up --build -d
if [ $? -ne 0 ]; then
  log_error "Failed to run Docker Compose"
  exit 1
fi
