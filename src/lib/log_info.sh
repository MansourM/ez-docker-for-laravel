log_info() {
  if [ "$#" -ne 1 ]; then
      echo -e "\nInvalid Arguments, Usage: $0 <message>\n"
      return 1
  fi

  BOLD_CYAN='\033[1;36m'
  NORMAL='\033[0m'

  echo -e "${BOLD_CYAN}-- $1${NORMAL}"
}
