#inspect_args

DELIMITER="exit"
PROMPT=$(get_prompt_text "Please paste the content of your .env file, " "type '$DELIMITER' on a new line and press enter to finish")
echo -e "$PROMPT"
ENV_CONTENT=$(read_multi_line_input "$DELIMITER")

APP_NAME=$(echo "$ENV_CONTENT" | grep -oP '^APP_NAME=\K.*')
APP_NAME=$(ask_question "Enter the application name" "$APP_NAME")

DATA_DIR="data/$APP_NAME"

if [[ -d "$DATA_DIR" ]]; then
    log_error "Directory $DATA_DIR already exists app_name must be unique."
    exit 1
fi

log "Creating $DATA_DIR directory"
mkdir -p "$DATA_DIR/env/generated"

COPY_ENV_TO="$DATA_DIR/env/laravel.env"

log "saving .env file into $COPY_ENV_TO"
echo "$ENV_CONTENT" > "$COPY_ENV_TO"

log_info "Git url examples:"
log "normal git url (you get prompted for authorization): https://github.com/MansourM/ez-docker-for-laravel.git"
log "or this format: https://<user>:<pass>@github.com/MansourM/ez-docker-for-laravel.git"
GIT_URL=$(ask_question "Enter the application git url" "https://<user>:<pass>@github.com/MansourM/ez-docker-for-laravel-example.git")

cat <<EOL > "$DATA_DIR/env/project.env"
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