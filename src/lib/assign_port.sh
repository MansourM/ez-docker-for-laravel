assign_port() {
  local environment=$1
  local base_port=$2
  local num_apps default_port app_port

  num_apps=$(ls -l apps | grep -c '^d')
  default_port=$((base_port + num_apps))

  while true; do
    app_port=$(ask_question "Enter the ${environment} app port" "$default_port")

    if is_port_in_use "$app_port"; then
      log_error "Port $app_port is already in use. Please choose a different port." >&2
    else
      echo "$app_port"  # This should be captured in the main script
      return 0
    fi
  done
}
