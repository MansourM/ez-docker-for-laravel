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
  # $DB_HOST & DB_ROOT_PASSWORD is read from docker.env

  # Check if database exists by querying INFORMATION_SCHEMA.SCHEMATA
  DB_EXISTS=$(docker exec -i $DB_HOST mysql -u"$MYSQL_USER" -p"$DB_ROOT_PASSWORD" -e \
      "SELECT COUNT(*) FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$NEW_DB_NAME';" --skip-column-names 2>/dev/null)

  if [[ "$DB_EXISTS" != "1" ]]; then
    # Database doesn't exist, so create it
    if ! docker exec -i $DB_HOST mysql -u"$MYSQL_USER" -p"$DB_ROOT_PASSWORD" -e "CREATE DATABASE \`$NEW_DB_NAME\`;"; then
      log_error "Failed to create database '$NEW_DB_NAME'"
      exit 1
    else
      log_success "Created Database: $NEW_DB_NAME"
    fi
  else
    log "Database: $NEW_DB_NAME Already Exists"
  fi

  #TODO how to give access to specific container instead of %?
  # Check if user exists
  if docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "SELECT user FROM mysql.user WHERE user='$NEW_USER_NAME';" --skip-column-names -B | grep -q "$NEW_USER_NAME"; then
      log_warning "User '$NEW_USER_NAME' already exists. Updating password."
      # Update user password
      if ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "ALTER USER '$NEW_USER_NAME'@'%' IDENTIFIED BY '$NEW_USER_PASSWORD';" || \
         ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON \`$NEW_DB_NAME\`.* TO '$NEW_USER_NAME'@'%';" || \
         ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"; then
        log_error "Failed to update password and/or grant privileges for user '$NEW_USER_NAME'"
        exit 1
      fi
      log_success "User: '$NEW_USER_NAME' password updated for DB: $NEW_DB_NAME with full privileges";
  else
      # Create user and grant privileges
      if ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "CREATE USER '$NEW_USER_NAME'@'%' IDENTIFIED BY '$NEW_USER_PASSWORD';" || \
         ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON \`$NEW_DB_NAME\`.* TO '$NEW_USER_NAME'@'%';" || \
         ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"; then
        log_error "Failed to create and grant privileges for user '$NEW_USER_NAME'"
        exit 1
      fi
      log_success "User: '$NEW_USER_NAME' created for DB: $NEW_DB_NAME with full privileges";
  fi
}
