#!/usr/bin/env bash
# Database Security Module
# Provides secure functions for database operations with SQL injection prevention

# Validate database name (alphanumeric and underscores only)
validate_db_name() {
  local db_name="$1"
  
  if [[ -z "$db_name" ]]; then
    log_error "Database name cannot be empty" 2>/dev/null || echo "ERROR: Database name cannot be empty" >&2
    return 1
  fi
  
  if [[ ! "$db_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
    log_error "Invalid database name: $db_name. Only alphanumeric and underscores allowed." 2>/dev/null || echo "ERROR: Invalid database name" >&2
    return 1
  fi
  
  if [ ${#db_name} -gt 64 ]; then
    log_error "Database name too long: maximum 64 characters" 2>/dev/null || echo "ERROR: Database name too long" >&2
    return 1
  fi
  
  return 0
}

# Validate username (alphanumeric and underscores only)
validate_username() {
  local username="$1"
  
  if [[ -z "$username" ]]; then
    log_error "Username cannot be empty" 2>/dev/null || echo "ERROR: Username cannot be empty" >&2
    return 1
  fi
  
  if [[ ! "$username" =~ ^[a-zA-Z0-9_]+$ ]]; then
    log_error "Invalid username: $username. Only alphanumeric and underscores allowed." 2>/dev/null || echo "ERROR: Invalid username" >&2
    return 1
  fi
  
  if [ ${#username} -gt 32 ]; then
    log_error "Username too long: maximum 32 characters" 2>/dev/null || echo "ERROR: Username too long" >&2
    return 1
  fi
  
  return 0
}

# Sanitize password for MySQL (escape single quotes)
sanitize_password_for_mysql() {
  local password="$1"
  
  if [[ -z "$password" ]]; then
    log_error "Password cannot be empty" 2>/dev/null || echo "ERROR: Password cannot be empty" >&2
    return 1
  fi
  
  # Escape single quotes by doubling them (MySQL standard)
  # This is safe for use within single-quoted strings in SQL
  local sanitized="${password//\'/\'\'}"
  
  echo "$sanitized"
  return 0
}

# Validate network restriction format
validate_network_restriction() {
  local network="$1"
  
  # Reject wildcard access
  if [[ "$network" == "%" ]]; then
    log_error "Wildcard host access (%) is not allowed for security" 2>/dev/null || echo "ERROR: Wildcard not allowed" >&2
    return 1
  fi
  
  # Reject 0.0.0.0 (all hosts)
  if [[ "$network" == "0.0.0.0" ]]; then
    log_error "Access from all hosts (0.0.0.0) is not allowed for security" 2>/dev/null || echo "ERROR: 0.0.0.0 not allowed" >&2
    return 1
  fi
  
  # Accept Docker network patterns (172.%.%.% or similar)
  if [[ "$network" =~ ^[0-9]+\.[0-9%]+\.[0-9%]+\.[0-9%]+$ ]]; then
    return 0
  fi
  
  log_error "Invalid network restriction format: $network" 2>/dev/null || echo "ERROR: Invalid network format" >&2
  return 1
}

# Execute MySQL command using here-doc to avoid bash interpolation
execute_mysql_command() {
  local sql_command="$1"
  local user="${2:-root}"
  local password="$3"
  local host="${4:-$DB_HOST}"
  
  if [[ -z "$sql_command" ]]; then
    log_error "SQL command cannot be empty" 2>/dev/null || echo "ERROR: SQL command empty" >&2
    return 1
  fi
  
  if [[ -z "$password" ]]; then
    log_error "Password is required for MySQL connection" 2>/dev/null || echo "ERROR: Password required" >&2
    return 1
  fi
  
  # Use here-doc to avoid bash variable interpolation in SQL
  # This prevents SQL injection through bash variables
  docker exec -i "$host" mysql -u"$user" -p"$password" <<EOF
$sql_command
EOF
  
  return $?
}

# Create database with validation and secure execution
create_database_secure() {
  local db_name="$1"
  
  # Validate database name
  if ! validate_db_name "$db_name"; then
    return 1
  fi
  
  # Use backticks for identifier quoting in MySQL
  local sql="CREATE DATABASE IF NOT EXISTS \`$db_name\`;"
  
  # Execute using secure method
  if execute_mysql_command "$sql" "root" "$DB_ROOT_PASSWORD"; then
    log_success "Database created: $db_name" 2>/dev/null || echo "SUCCESS: Database created" >&2
    return 0
  else
    log_error "Failed to create database: $db_name" 2>/dev/null || echo "ERROR: Database creation failed" >&2
    return 1
  fi
}

# Create user with network restriction and secure execution
create_user_secure() {
  local username="$1"
  local password="$2"
  local db_name="$3"
  local network_restriction="${4:-172.%.%.%}"
  
  # Validate inputs
  if ! validate_username "$username"; then
    return 1
  fi
  
  if ! validate_db_name "$db_name"; then
    return 1
  fi
  
  if ! validate_network_restriction "$network_restriction"; then
    return 1
  fi
  
  # Sanitize password
  local sanitized_password
  sanitized_password=$(sanitize_password_for_mysql "$password")
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  
  # Create user with network restriction
  local sql="CREATE USER IF NOT EXISTS '$username'@'$network_restriction' IDENTIFIED BY '$sanitized_password';"
  
  if ! execute_mysql_command "$sql" "root" "$DB_ROOT_PASSWORD"; then
    log_error "Failed to create user: $username" 2>/dev/null || echo "ERROR: User creation failed" >&2
    return 1
  fi
  
  # Grant privileges
  sql="GRANT ALL PRIVILEGES ON \`$db_name\`.* TO '$username'@'$network_restriction';"
  
  if ! execute_mysql_command "$sql" "root" "$DB_ROOT_PASSWORD"; then
    log_error "Failed to grant privileges to user: $username" 2>/dev/null || echo "ERROR: Grant failed" >&2
    return 1
  fi
  
  # Flush privileges
  sql="FLUSH PRIVILEGES;"
  
  if ! execute_mysql_command "$sql" "root" "$DB_ROOT_PASSWORD"; then
    log_warning "Failed to flush privileges" 2>/dev/null || echo "WARNING: Flush failed" >&2
  fi
  
  log_success "User created with network restriction: $username@$network_restriction" 2>/dev/null || echo "SUCCESS: User created" >&2
  return 0
}

# Update user password with secure execution
update_user_password_secure() {
  local username="$1"
  local password="$2"
  local network_restriction="${3:-172.%.%.%}"
  
  # Validate inputs
  if ! validate_username "$username"; then
    return 1
  fi
  
  if ! validate_network_restriction "$network_restriction"; then
    return 1
  fi
  
  # Sanitize password
  local sanitized_password
  sanitized_password=$(sanitize_password_for_mysql "$password")
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  
  # Update password
  local sql="ALTER USER '$username'@'$network_restriction' IDENTIFIED BY '$sanitized_password';"
  
  if execute_mysql_command "$sql" "root" "$DB_ROOT_PASSWORD"; then
    log_success "Password updated for user: $username" 2>/dev/null || echo "SUCCESS: Password updated" >&2
    return 0
  else
    log_error "Failed to update password for user: $username" 2>/dev/null || echo "ERROR: Password update failed" >&2
    return 1
  fi
}

# Check if user exists
user_exists() {
  local username="$1"
  local network_restriction="${2:-172.%.%.%}"
  
  if ! validate_username "$username"; then
    return 1
  fi
  
  local sql="SELECT user FROM mysql.user WHERE user='$username' AND host='$network_restriction';"
  local result
  
  result=$(execute_mysql_command "$sql" "root" "$DB_ROOT_PASSWORD" 2>/dev/null | grep -c "$username")
  
  if [[ "$result" -gt 0 ]]; then
    return 0  # User exists
  else
    return 1  # User does not exist
  fi
}

# Check if database exists
database_exists() {
  local db_name="$1"
  
  if ! validate_db_name "$db_name"; then
    return 1
  fi
  
  local sql="SHOW DATABASES LIKE '$db_name';"
  local result
  
  result=$(execute_mysql_command "$sql" "root" "$DB_ROOT_PASSWORD" 2>/dev/null | grep -c "$db_name")
  
  if [[ "$result" -gt 0 ]]; then
    return 0  # Database exists
  else
    return 1  # Database does not exist
  fi
}
