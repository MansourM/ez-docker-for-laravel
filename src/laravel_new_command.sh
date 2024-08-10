DELIMITER="exit"
PROMPT=$(get_prompt_text "Please paste the content of your .env file, " "type '$DELIMITER' on a new line and press enter to finish")
echo -e "$PROMPT"
ENV_CONTENT=$(read_multi_line_input "$DELIMITER")

APP_NAME=$(echo "$ENV_CONTENT" | grep -oP '^APP_NAME=\K.*')
APP_NAME=$(ask_question "Enter the application name" "$APP_NAME")

while true; do
  OWNER_USER_NAME=$(ask_question "What user on this host machine owns this app" "$(whoami)")

  if user_exists "$OWNER_USER_NAME"; then
    break
  else
    log_error "User '$OWNER_USER_NAME' does not exist. Please enter a valid user."
  fi
done
OWNER_USER_ID=$(id -u "$OWNER_USER_NAME")
OWNER_GROUP_NAME=$(id -gn "$OWNER_USER_NAME")
OWNER_GROUP_ID=$(id -g "$OWNER_USER_NAME")

APP_DIR="apps/$APP_NAME"

if [[ -d "$APP_DIR" ]]; then
    log_error "Directory $APP_DIR already exists app_name must be unique."
    exit 1
fi

log "Creating $APP_DIR directory"
mkdir -p "$APP_DIR/env/generated"

log "saving .env file into $APP_DIR/env/laravel.env"
echo "$ENV_CONTENT" > "$APP_DIR/env/laravel.env"

log_info "Git url examples:"
log "normal git url (you get prompted for authorization): https://github.com/MansourM/ez-docker-for-laravel.git"
log "or this format: https://<user>:<pass>@github.com/MansourM/ez-docker-for-laravel.git"
GIT_URL=$(ask_question "Enter the application git url" "https://github.com/MansourM/ez-docker-for-laravel-example.git")

cat <<EOL > "$APP_DIR/env/app.env"
APP_NAME=$APP_NAME
GIT_URL=$GIT_URL
OWNER_USER_NAME=$OWNER_USER_NAME
OWNER_USER_ID=$OWNER_USER_ID
OWNER_GROUP_NAME=$OWNER_GROUP_NAME
OWNER_GROUP_ID=$OWNER_GROUP_ID
EOL

log_success "created $APP_DIR/env/app.env"

SETUP_DEV_ENV=$(ask_question "Do you want to set up the dev environment?" "yes")

if [[ "$SETUP_DEV_ENV" == "yes" || "$SETUP_DEV_ENV" == "y" ]]; then
  setup_environment "$APP_NAME" "dev"
fi

SETUP_TEST_ENV=$(ask_question "Do you want to set up the test environment?" "yes")

if [[ "$SETUP_TEST_ENV" == "yes" || "$SETUP_TEST_ENV" == "y" ]]; then
  setup_environment "$APP_NAME" "test"
fi

SETUP_STAGING_ENV=$(ask_question "Do you want to set up the staging environment?" "yes")

if [[ "$SETUP_STAGING_ENV" == "yes" || "$SETUP_TEST_ENV" == "y" ]]; then
  setup_environment "$APP_NAME" "staging"
fi

SETUP_STAGING_ENV=$(ask_question "Do you want to set up the production environment?" "yes")

if [[ "$SETUP_STAGING_ENV" == "yes" || "$SETUP_TEST_ENV" == "y" ]]; then
  setup_environment "$APP_NAME" "production"
fi

cp -r "template/nginx" "$APP_DIR/nginx"
cp "template/entrypoint.sh" "$APP_DIR/entrypoint.sh"
cp "template/entrypoint-dev.sh" "$APP_DIR/entrypoint-dev.sh"
cp "template/opcache.ini" "$APP_DIR/opcache.ini"
cp "template/php.ini" "$APP_DIR/php.ini"
cp "template/supervisord.conf" "$APP_DIR/supervisord.conf"

cp "template/common-laravel.yml" "$APP_DIR/common-laravel.yml"
cp "template/laravel-dev.Dockerfile" "$APP_DIR/laravel-dev.Dockerfile"
cp "template/laravel.Dockerfile" "$APP_DIR/laravel.Dockerfile"
cp "template/compose-laravel.yml" "$APP_DIR/compose-laravel.yml"
