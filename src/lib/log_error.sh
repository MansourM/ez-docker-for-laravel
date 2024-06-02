log_error() {
  if [ "$#" -ne 1 ]; then
      echo -e "\nInvalid Arguments, Usage: $0 <message>\n"
      return 1
  fi

  RED='\033[0;31m'
  NORMAL='\033[0m'

  echo -e "${RED}-- $1${NORMAL}"
}
