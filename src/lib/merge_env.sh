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
merge_env() {
  local file1="$1"
  local file2="$2"
  local output="$3"

  if [ ! -e "$file1" ]; then
    log_error "$file1 does not exist!"
    exit 1
  fi

  if [ ! -e "$file2" ]; then
    log_error "$file2 does not exist!"
    exit 1
  fi

  sort -u -t '=' -k 1,1 $file2 $file1 | grep -v '^$\|^\s*\#' > $output

  log_success "Merged $file2 into $file1 file creating $output."
}
