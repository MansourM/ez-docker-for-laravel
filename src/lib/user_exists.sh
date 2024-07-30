user_exists() {
  local username=$1
  id -u "$username" >/dev/null 2>&1
}
