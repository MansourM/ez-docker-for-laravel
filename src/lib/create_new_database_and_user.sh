# Source the secure database functions
source "$(dirname "${BASH_SOURCE[0]}")/security/db_security.sh"

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

  # $DB_HOST & DB_ROOT_PASSWORD is read from docker.env
  # Get network restriction from .env or use default
  local NETWORK_RESTRICTION="${DB_NETWORK_RESTRICTION:-172.%.%.%}"

  # Check if database exists using secure function
  if database_exists "$NEW_DB_NAME"; then
    log "Database: $NEW_DB_NAME Already Exists"
  else
    # Create database using secure function
    if ! create_database_secure "$NEW_DB_NAME"; then
      log_error "Failed to create database '$NEW_DB_NAME'"
      exit 1
    fi
  fi

  # Check if user exists with network restriction
  if user_exists "$NEW_USER_NAME" "$NETWORK_RESTRICTION"; then
      log_warning "User '$NEW_USER_NAME'@'$NETWORK_RESTRICTION' already exists. Updating password."
      
      # Update user password using secure function
      if ! update_user_password_secure "$NEW_USER_NAME" "$NEW_USER_PASSWORD" "$NETWORK_RESTRICTION"; then
        log_error "Failed to update password for user '$NEW_USER_NAME'"
        exit 1
      fi
      
      # Grant privileges (in case they changed)
      local sql="GRANT ALL PRIVILEGES ON \`$NEW_DB_NAME\`.* TO '$NEW_USER_NAME'@'$NETWORK_RESTRICTION';"
      if ! execute_mysql_command "$sql" "root" "$DB_ROOT_PASSWORD"; then
        log_error "Failed to grant privileges for user '$NEW_USER_NAME'"
        exit 1
      fi
      
      log_success "User: '$NEW_USER_NAME'@'$NETWORK_RESTRICTION' password updated for DB: $NEW_DB_NAME with full privileges"
  else
      # Create user and grant privileges using secure function
      if ! create_user_secure "$NEW_USER_NAME" "$NEW_USER_PASSWORD" "$NEW_DB_NAME" "$NETWORK_RESTRICTION"; then
        log_error "Failed to create and grant privileges for user '$NEW_USER_NAME'"
        exit 1
      fi
      
      log_success "User: '$NEW_USER_NAME'@'$NETWORK_RESTRICTION' created for DB: $NEW_DB_NAME with full privileges"
  fi
}
