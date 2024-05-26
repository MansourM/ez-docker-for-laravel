setup_environment() {
    local app_name=$1
    local environment=$2

    local branch_name db_name db_username generated_password db_password data_dir

    branch_name=$(ask_question "Enter the test branch name" "$environment")

    db_name=$(ask_question "Enter the test database name" "${app_name}_${environment}")
    db_username=$(ask_question "Enter the ${environment} database username" "${app_name}_${environment}_user")
    generated_password=$(generate_password 16)
    db_password=$(ask_question "Enter the $db_username's password" "$generated_password")

    data_dir="data/$app_name"
    log "Creating $data_dir directory"
    mkdir -p "$data_dir/env"

    cat <<EOL > "$data_dir/env/$environment.env"
APP_NAME=$app_name
APP_PORT=$APP_PORT
DB_NAME=$db_name
DB_USERNAME=$db_username
DB_PASSWORD=$db_password
EOL

    echo "$branch_name"
    echo "$db_name"
    echo "$db_username"
    echo "$db_password"
}