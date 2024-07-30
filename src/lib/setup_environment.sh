setup_environment() {
  local app_name=$1
  local environment=$2

  local branch_name db_database db_username generated_password db_password app_debug

  if [ "$environment" == "production" ]; then
    branch_name="main"
  else
    branch_name="$environment"
  fi

  branch_name=$(ask_question "Enter the ${environment} branch name" "$branch_name")

  db_database=$(ask_question "Enter the ${environment} database name" "${app_name}_${environment}")
  db_username=$(ask_question "Enter the ${environment} database username" "${app_name}_${environment}_user")
  generated_password=$(generate_password 20)
  db_password=$(ask_question "Enter the $db_username's password" "$generated_password")

  if [[ "$environment" == "dev" ]]; then
    app_debug=true
    app_port=$(assign_port "dev" 7000)  # Directly capture the correct port
  elif [[ "$environment" == "test" ]]; then
    app_debug=true
    app_port=$(assign_port "test" 8000)  # Directly capture the correct port
  else
    app_debug=false
  fi


  #FIXME do something for APP_URL
  cat <<EOL > "apps/$app_name/env/$environment.env"
GIT_BRANCH=$branch_name
APP_ENV=$environment
APP_DEBUG=$app_debug
APP_URL=$environment.my.url
APP_PORT=$app_port
DB_DATABASE=$db_database
DB_USERNAME=$db_username
DB_PASSWORD=$db_password
EOL

}
