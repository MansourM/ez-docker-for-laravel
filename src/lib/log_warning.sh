log_warning() {
  if [ "$#" -ne 1 ]; then
      echo -e "\nInvalid Arguments, Usage: $0 <message>\n"
      return 1
  fi

  YELLOW='\033[0;33m'
  NORMAL='\033[0m'

  echo -e "${YELLOW}-- $1${NORMAL}"
}
