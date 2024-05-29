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
merge_envs() {
  if [ "$#" -lt 3 ]; then
    log_error "Usage: merge_env <output> <file1> <file2> [file3 ... fileN]"
    exit 1
  fi

  local output="$1"
  shift
  local temp_output=$(mktemp)

  # Verify that all input files exist
  for file in "$@"; do
    if [ ! -e "$file" ]; then
      log_error "$file does not exist!"
      exit 1
    fi
  done

  # Start with the first file
  sort -u -t '=' -k 1,1 "$1" | grep -v '^$\|^\s*\#' > "$temp_output"
  shift

  # Merge remaining files
  for file in "$@"; do
    sort -u -t '=' -k 1,1 "$file" "$temp_output" | grep -v '^$\|^\s*\#' > "$output"
    cp "$output" "$temp_output"
  done

  mv "$temp_output" "$output"
  log_success "Merged files into $output."
}
