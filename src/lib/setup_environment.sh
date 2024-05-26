setup_environment() {
    local app_name=$1
    local environment=$2

    BRANCH_NAME=$(ask_question "Enter the test branch name" "$environment")

    DB_NAME=$(ask_question "Enter the test database name" "${app_name}_${environment}")
    DB_USERNAME=$(ask_question "Enter the ${environment} database username" "${app_name}_${environment}_user")
    GENERATED_PASSWORD=$(generate_password 16)
    DB_PASSWORD=$(ask_question "Enter the $DB_USERNAME 's password'" "$GENERATED_PASSWORD")

    echo "$BRANCH_NAME"
    echo "$DB_NAME"
    echo "$DB_USERNAME"
    echo "$DB_PASSWORD"
}