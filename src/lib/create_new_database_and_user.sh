## Add any function here that is needed in more than one parts of your
## application, or that you otherwise wish to extract from the main function
## scripts.
##
## Note that code here should be wrapped inside bash functions, and it is
## recommended to have a separate file for each function.
##
## Subdirectories will also be scanned for *.sh, so you have no reason not
## to organize your code neatly.
##
create_new_database_and_user() {

  if [ "$#" -ne 3 ]; then
      log_error "Invalid Arguments, Usage: $0 <new_db_name> <new_user_name> <new_user_password>"
      return 1
  fi

  # Set variables
  NEW_DB_NAME=$1
  NEW_USER_NAME=$2
  NEW_USER_PASSWORD=$3

  log_header "Creating Database: $NEW_DB_NAME with User: $NEW_USER_NAME"

  MYSQL_USER="root"
  # DB_ROOT_PASSWORD is read from docker.env

  # Check if database exists (improve error handling)
  if ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "SELECT 1 FROM \`$NEW_DB_NAME\`;" > /dev/null 2>&1; then
    # Create database
    if ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS \`$NEW_DB_NAME\`;"; then
      log
      log_error "Failed to create database '$NEW_DB_NAME'"
      exit 1
    fi
    log_success "Created Database: $NEW_DB_NAME";
  else
    log "Database: $NEW_DB_NAME Already Exists";
  fi

  #TODO how to give access to specific container instead of %?
  # Check if user exists (improve error handling)
  if ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "SELECT user FROM mysql.user WHERE user='$NEW_USER_NAME';" --skip-column-names -B | grep -q "$NEW_USER_NAME"; then
    # Create user and grant privileges
    if ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "CREATE USER '$NEW_USER_NAME'@'%' IDENTIFIED BY '$NEW_USER_PASSWORD';" || \
       ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON \`$NEW_DB_NAME\`.* TO '$NEW_USER_NAME'@'%';" || \
       ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"; then
      log_error "Failed to create and grant privileges for user '$NEW_USER_NAME'"
      exit 1
    fi
    log_success "User: '$NEW_USER_NAME' created for DB: $NEW_DB_NAME with full privileges";
  else
    log "User '$NEW_USER_NAME' already exists";
  fi
}
