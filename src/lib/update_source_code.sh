update_source_code() {
  log_info "updating source code ..."
  local source_code_dir="apps/${args[APP_NAME]}/src-${args[APP_ENV]}"

  # If the source code directory exists, update the repo
  #TODO add a force clone config somewhere so user can choose to always clone instead of updating the repo?
  if [ -d "$source_code_dir" ]; then
      log "Updating existing $source_code_dir folder"

      cd "$source_code_dir" || exit 1

      git pull origin "$GIT_BRANCH"
      if [ $? -ne 0 ]; then
          log_error "Error: Git pull failed."
          exit 1
      fi

      cd - || exit 1
  else
      # If the source code directory doesn't exist, clone the repo
      log "Cloning new $source_code_dir folder"
      git clone --depth 1 -b "$GIT_BRANCH" "$GIT_URL" "$source_code_dir"

      # Check if cloning was successful
      if [ $? -ne 0 ]; then
          log_error "Error: Git cloning failed."
          exit 1
      fi
  fi
}
