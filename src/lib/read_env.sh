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
read_env() {
  local filename="${1:-.env}"

  if [ ! -f "$filename" ]; then
    echo "missing ${filename} file"
    exit 1
  fi

  echo "reading .env file..."
  while read -r LINE; do
    if [[ $LINE != '#'* ]] && [[ $LINE == *'='* ]]; then
      export "$LINE"
    fi
  done < "$filename"
}
