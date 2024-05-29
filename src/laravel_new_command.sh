#inspect_args

DELIMITER="exit"
PROMPT=$(get_prompt_text "Please paste the content of your .env file, " "type '$DELIMITER' on a new line and press enter to finish")
echo -e "$PROMPT"
ENV_CONTENT=$(read_multi_line_input "$DELIMITER")

APP_NAME=$(echo "$ENV_CONTENT" | grep -oP '^APP_NAME=\K.*')
APP_NAME=$(ask_question "Enter the application name" "$APP_NAME")

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
GIT_URL=$GIT_URL
EOL

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

cp "template/nginx" "$APP_DIR/nginx"
cp "template/entrypoint.sh" "$APP_DIR/entrypoint.sh"
cp "template/opcache.ini" "$APP_DIR/opcache.ini"
cp "template/php.ini" "$APP_DIR/php.ini"
cp "template/supervisord.conf" "$APP_DIR/supervisord.conf"

cp "template/common-laravel.yml" "$APP_DIR/common-laravel.yml"
cp "template/laravel.Dockerfile" "$APP_DIR/laravel.Dockerfile"
cp "template/compose-laravel.yml" "$APP_DIR/compose-laravel.yml"