create_docker_env() {
  cat <<EOL > "$DOCKER_ENV_PATH"
  SHARED_NETWORK_NAME=$SHARED_NETWORK_NAME

  PORT_NGINX_PM=$PORT_NGINX_PM
  PORT_PMA=$PORT_PMA

  DB_HOST=mysql8
  DB_PORT=3306
  DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD
EOL

  log_success "Saved docker environment variables to $DOCKER_ENV_PATH"
}
