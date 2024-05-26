#inspect_args

DELIMITER="exit"
PROMPT=$(get_prompt_text "Please paste the content of your .env file, " "type '$DELIMITER' on a new line and press enter to finish")
echo -e "$PROMPT"
ENV_CONTENT=$(read_multi_line_input "$DELIMITER")

APP_NAME=$(echo "$ENV_CONTENT" | grep -oP '^APP_NAME=\K.*')
APP_NAME=$(ask_question "Enter the application name" "$APP_NAME")

DATA_DIR="data/$APP_NAME"

if [[ -d "$DATA_DIR" ]]; then
    log_error "Directory $DATA_DIR already exists app_name must be unique. Exiting."
    exit 1
fi



GIT_URL=$(ask_question "Enter the application git url" "https://github.com/MansourM/ez-docker-for-laravel-example.git")
SETUP_TEST_ENV=$(ask_question "Do you want to set up the test environment?" "yes")

echo "$APP_NAME"
echo "$GIT_URL"
echo "$SETUP_TEST_ENV"

if [[ "$SETUP_TEST_ENV" == "yes" ]]; then
  setup_environment "$APP_NAME" "test"
fi

SETUP_STAGING_ENV=$(ask_question "Do you want to set up the staging environment?" "yes")

if [[ "$SETUP_STAGING_ENV" == "yes" ]]; then
  setup_environment "$APP_NAME" "staging"
fi

SETUP_STAGING_ENV=$(ask_question "Do you want to set up the production environment?" "yes")

if [[ "$SETUP_STAGING_ENV" == "yes" ]]; then
  setup_environment "$APP_NAME" "production"
fi