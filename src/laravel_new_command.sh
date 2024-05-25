#inspect_args

DEFAULT_APP_NAME="my_app"
DEFAULT_APP_PORT="8080"

# Ask the user for the application name and port
APP_NAME=$(ask_question "Enter the application name" $DEFAULT_APP_NAME)
APP_PORT=$(ask_question "Enter the application port" $DEFAULT_APP_PORT)

echo "$APP_NAME"
echo "$APP_PORT"

DATA_DIR="data/$APP_NAME"

if [[ -d "$DATA_DIR" ]]; then
    log_error "Directory $DATA_DIR already exists. Exiting."
    exit 1
fi