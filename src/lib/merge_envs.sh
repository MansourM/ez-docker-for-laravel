merge_envs() {
  if [ "$#" -lt 3 ]; then
    log_error "Usage: merge_env <output> <file1> <file2> [file3 ... fileN]"
    exit 1
  fi

  local output="$1"
  shift

  local merged_content=""

  for file in "$@"; do
    if [ ! -e "$file" ]; then
      log_error "$file does not exist!"
      exit 1
    fi

    # Sort, filter, and remove duplicates from merged content
    merged_content=$(sort -u -t '=' -k 1,1 "$file" <(printf "%s" "$merged_content") | grep -v '^$\|^\s*\#')
  done

  #Mask some vars from being merged into others, TODO improve this part
  merged_content=$(echo "$merged_content" | grep -Ev '^(SHARED_NETWORK_NAME|PORT_NGINX_PM|PORT_PMA|DB_ROOT_PASSWORD)=')

  echo "$merged_content" > "$output"
  log_success "Merged files into $output."
}
