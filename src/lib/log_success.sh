log_success() {
  if [ "$#" -ne 1 ]; then
      echo -e "\nInvalid Arguments, Usage: $0 <message>\n"
      return 1
  fi

  GREEN='\033[0;32m'
  NORMAL='\033[0m'

  echo -e "${GREEN}-- $1${NORMAL}"
}
