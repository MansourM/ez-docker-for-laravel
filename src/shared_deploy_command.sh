#inspect_args
if [[ -f "config/docker.env" ]]; then
  load_env "config/docker.env"
else
  log "config/docker.env not found."
  PORT_NGINX_PM=$(ask_question "Enter the Nginx Proxy Manager port" "8011")
  PORT_PMA=$(ask_question "Enter the PhpMyAdmin port" "8022")
  GENERATED_PASSWORD=$(generate_password 24)
  DB_ROOT_PASSWORD=$(ask_question "Enter the database root password" "$GENERATED_PASSWORD" )
  SHARED_NETWORK_NAME=$(ask_question "Enter the docker network name" "ez-shared-network")

  # Save the user input to config/docker.env for future use
  mkdir -p config
  cat <<EOL > config/docker.env
PORT_NGINX_PM=$PORT_NGINX_PM
PORT_PMA=$PORT_PMA
DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD
SHARED_NETWORK_NAME=$SHARED_NETWORK_NAME
EOL

  log_success "Saved environment variables to config/docker.env"
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

#TODO read APP_ENV from cli args and ignore APP_ENV in .env?
# Check if APP_ENV is set to dev, test, staging, or production
if [[ "$APP_ENV" != "dev" && "$APP_ENV" != "test" && "$APP_ENV" != "staging" && "$APP_ENV" != "production" ]]; then
    log_error "Error: Invalid value for APP_ENV. It must be either dev, test, staging, or production."
    exit 1
fi

log_header "Running Docker Compose for shared services"

docker compose -f compose-shared.yml --env-file "env/.env" --env-file "env/shared.env" up --build -d
if [ $? -ne 0 ]; then
  log_error "Failed to run Docker Compose"
  exit 1
fi
