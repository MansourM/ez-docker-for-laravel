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
log_warning() {
  if [ "$#" -ne 1 ]; then
      echo -e "\nInvalid Arguments, Usage: $0 <message>\n"
      return 1
  fi

  local YELLOW='\033[0;33m'
  NORMAL='\033[0m'

  echo -e "${YELLOW}-- $1${NORMAL}"
}
