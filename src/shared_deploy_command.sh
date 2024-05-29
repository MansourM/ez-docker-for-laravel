#inspect_args

if [[ -f "docker/docker.env" ]]; then
  load_env "docker/docker.env"
else
  log "docker/docker.env not found."
  PORT_NGINX_PM=$(ask_question "Enter the Nginx Proxy Manager port" "7000")
  PORT_PMA=$(ask_question "Enter the PhpMyAdmin port" "7001")
  GENERATED_PASSWORD=$(generate_password 24)
  DB_ROOT_PASSWORD=$(ask_question "Enter the database root password" "$GENERATED_PASSWORD" )
  SHARED_NETWORK_NAME=$(ask_question "Enter the docker network name" "ez-shared-network")

  mkdir -p config
  cat <<EOL > docker/docker.env
SHARED_NETWORK_NAME=$SHARED_NETWORK_NAME

PORT_NGINX_PM=$PORT_NGINX_PM
PORT_PMA=$PORT_PMA

DB_HOST=mysql8
DB_PORT=3306
DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD
EOL

  log_success "Saved docker environment variables to config/docker.env"
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
