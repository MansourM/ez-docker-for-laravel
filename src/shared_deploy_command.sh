#inspect_args

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

echo -e "\n==[ Running Docker Compose for shared services ]==\n"

docker compose -f compose-shared.yml --env-file "env/.env" --env-file "env/shared.env" up --build -d
if [ $? -ne 0 ]; then
  log_error "Failed to run Docker Compose"
  exit 1
fi
