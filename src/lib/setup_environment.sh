setup_environment() {
    local app_name=$1
    local environment=$2

    local branch_name db_database db_username generated_password db_password data_dir app_debug

    if [ "$environment" == "test" ]; then
      app_debug=true
    else
      app_debug=false
    fi

    branch_name=$(ask_question "Enter the test branch name" "$environment")

    db_database=$(ask_question "Enter the test database name" "${app_name}_${environment}")
    db_username=$(ask_question "Enter the ${environment} database username" "${app_name}_${environment}_user")
    generated_password=$(generate_password 16)
    db_password=$(ask_question "Enter the $db_username's password" "$generated_password")

    data_dir="data/$app_name"
    log "Creating $data_dir directory"
    mkdir -p "$data_dir/env"

    cat <<EOL > "$data_dir/env/$environment.env"
GIT_BRANCH=$branch_name
APP_ENV=$environment
APP_DEBUG=$app_debug
APP_URL=$environment.my.url
DB_DATABASE=$db_database
DB_USERNAME=$db_username
DB_PASSWORD=$db_password
EOL

}