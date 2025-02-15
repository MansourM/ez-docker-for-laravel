DOCKER_ENV_PATH="docker/docker.env"

if [[ -f "$DOCKER_ENV_PATH" ]]; then
  load_env "$DOCKER_ENV_PATH"
else
  log_warning "$DOCKER_ENV_PATH not found."
  log_info "Creating new '$DOCKER_ENV_PATH' file."

  PORT_NGINX_PM=$(ask_question "Enter the Nginx Proxy Manager port" "81")
  PORT_PMA=$(ask_question "Enter the PhpMyAdmin port" "6001")
  GENERATED_PASSWORD=$(generate_password 24)
  DB_ROOT_PASSWORD=$(ask_question "Enter the database root password" "$GENERATED_PASSWORD" )
  SHARED_NETWORK_NAME=$(ask_question "Enter the docker network name" "ez-shared-network")

  cat <<EOL > "$DOCKER_ENV_PATH"
SHARED_NETWORK_NAME=$SHARED_NETWORK_NAME

PORT_NGINX_PM=$PORT_NGINX_PM
PORT_PMA=$PORT_PMA

DB_HOST=mysql8
DB_PORT=3306
DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD
EOL

  log_success "Saved docker environment variables to $DOCKER_ENV_PATH"
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
