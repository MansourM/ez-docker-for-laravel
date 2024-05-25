#inspect_args

DEFAULT_APP_NAME="my_app"
DEFAULT_GIT_URL="https://github.com/MansourM/ez-docker-for-laravel-example.git"

# Ask the user for the application name and port
APP_NAME=$(ask_question "Enter the application name" $DEFAULT_APP_NAME)
GIT_URL=$(ask_question "Enter the application git url" $DEFAULT_GIT_URL)

echo "$APP_NAME"
echo "$GIT_URL"

DATA_DIR="data/$APP_NAME"

if [[ -d "$DATA_DIR" ]]; then
    log_error "Directory $DATA_DIR already exists. Exiting."
    exit 1
fi