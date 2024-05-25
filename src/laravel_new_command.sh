#inspect_args

DELIMITER="exit"
PROMPT=$(get_prompt_text "Please paste the content of your .env file, " "type $DELIMITER on a new line to finish")
echo -e "$PROMPT"
ENV_CONTENT=$(read_multi_line_input "$DELIMITER")

APP_NAME=$(echo "$ENV_CONTENT" | grep -oP '^APP_NAME=\K.*')
echo "$APP_NAME"
echo "////"
echo "$ENV_CONTENT"
#APP_NAME=$(ask_question "Enter the application name" "my_app")
GIT_URL=$(ask_question "Enter the application git url" "https://github.com/MansourM/ez-docker-for-laravel-example.git")
SETUP_TEST_ENV=$(ask_question "Do you want to set up the test environment?" "yes")

echo "$APP_NAME"
echo "$GIT_URL"
echo "$SETUP_TEST_ENV"

if [[ "$SETUP_TEST_ENV" == "yes" ]]; then

    TEST_BRANCH_NAME=$(ask_question "Enter the test branch name" "test")

    TEST_DB_NAME=$(ask_question "Enter the test database name" "${APP_NAME}_test")
    TEST_DB_USERNAME=$(ask_question "Enter the test database username" "${APP_NAME}_test_user")
    GENERATED_PASSWORD=$(generate_password 16)
    TEST_DB_PASSWORD=$(ask_question "Enter the $TEST_DB_USERNAME 's password'" "$GENERATED_PASSWORD")

    echo "$TEST_BRANCH_NAME"
    echo "$TEST_DB_NAME"
    echo "$TEST_DB_USERNAME"
    echo "$TEST_DB_PASSWORD"
fi



DATA_DIR="data/$APP_NAME"

if [[ -d "$DATA_DIR" ]]; then
    log_error "Directory $DATA_DIR already exists. Exiting."
    exit 1
fi