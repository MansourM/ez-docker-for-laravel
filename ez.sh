#!/usr/bin/env bash
#       _                 _
#   ___(_)_ __ ___  _ __ | | ___
#  / __| | '_ ` _ \| '_ \| |/ _ \
#  \__ \ | | | | | | |_) | |  __/
#  |___/_|_| |_| |_| .__/|_|\___|
#                  |_|
#
# Boilerplate for creating a simple bash script with some basic strictness
# checks and help features.
#
# Usage:
#   bash-simple <options>...
#
# Depends on:
#  list
#  of
#  programs
#  expected
#  in
#  environment
#
# Bash Boilerplate: https://github.com/xwmx/bash-boilerplate
#
# Copyright (c) 2015 William Melody • hi@williammelody.com

# Notes #######################################################################

# Extensive descriptions are included for easy reference.
#
# Explicitness and clarity are generally preferable, especially since bash can
# be difficult to read. This leads to noisier, longer code, but should be
# easier to maintain. As a result, some general design preferences:
#
# - Use leading underscores on internal variable and function names in order
#   to avoid name collisions. For unintentionally global variables defined
#   without `local`, such as those defined outside of a function or
#   automatically through a `for` loop, prefix with double underscores.
# - Always use braces when referencing variables, preferring `${NAME}` instead
#   of `$NAME`. Braces are only required for variable references in some cases,
#   but the cognitive overhead involved in keeping track of which cases require
#   braces can be reduced by simply always using them.
# - Prefer `printf` over `echo`. For more information, see:
#   http://unix.stackexchange.com/a/65819
# - Prefer `$_explicit_variable_name` over names like `$var`.
# - Use the `#!/usr/bin/env bash` shebang in order to run the preferred
#   Bash version rather than hard-coding a `bash` executable path.
# - Prefer splitting statements across multiple lines rather than writing
#   one-liners.
# - Group related code into sections with large, easily scannable headers.
# - Describe behavior in comments as much as possible, assuming the reader is
#   a programmer familiar with the shell, but not necessarily experienced
#   writing shell scripts.

###############################################################################
# Strict Mode
###############################################################################

# Treat unset variables and parameters other than the special parameters ‘@’ or
# ‘*’ as an error when performing parameter expansion. An 'unbound variable'
# error message will be written to the standard error, and a non-interactive
# shell will exit.
#
# This requires using parameter expansion to test for unset variables.
#
# http://www.gnu.org/software/bash/manual/bashref.html#Shell-Parameter-Expansion
#
# The two approaches that are probably the most appropriate are:
#
# ${parameter:-word}
#   If parameter is unset or null, the expansion of word is substituted.
#   Otherwise, the value of parameter is substituted. In other words, "word"
#   acts as a default value when the value of "$parameter" is blank. If "word"
#   is not present, then the default is blank (essentially an empty string).
#
# ${parameter:?word}
#   If parameter is null or unset, the expansion of word (or a message to that
#   effect if word is not present) is written to the standard error and the
#   shell, if it is not interactive, exits. Otherwise, the value of parameter
#   is substituted.
#
# Examples
# ========
#
# Arrays:
#
#   ${some_array[@]:-}              # blank default value
#   ${some_array[*]:-}              # blank default value
#   ${some_array[0]:-}              # blank default value
#   ${some_array[0]:-default_value} # default value: the string 'default_value'
#
# Positional variables:
#
#   ${1:-alternative} # default value: the string 'alternative'
#   ${2:-}            # blank default value
#
# With an error message:
#
#   ${1:?'error message'}  # exit with 'error message' if variable is unbound
#
# Short form: set -u
set -o nounset

# Exit immediately if a pipeline returns non-zero.
#
# NOTE: This can cause unexpected behavior. When using `read -rd ''` with a
# heredoc, the exit status is non-zero, even though there isn't an error, and
# this setting then causes the script to exit. `read -rd ''` is synonymous with
# `read -d $'\0'`, which means `read` until it finds a `NUL` byte, but it
# reaches the end of the heredoc without finding one and exits with status `1`.
#
# Two ways to `read` with heredocs and `set -e`:
#
# 1. set +e / set -e again:
#
#     set +e
#     read -rd '' variable <<HEREDOC
#     HEREDOC
#     set -e
#
# 2. Use `<<HEREDOC || true:`
#
#     read -rd '' variable <<HEREDOC || true
#     HEREDOC
#
# More information:
#
# https://www.mail-archive.com/bug-bash@gnu.org/msg12170.html
#
# Short form: set -e
set -o errexit

# Print a helpful message if a pipeline with non-zero exit code causes the
# script to exit as described above.
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR

# Allow the above trap be inherited by all functions in the script.
#
# Short form: set -E
set -o errtrace

# Return value of a pipeline is the value of the last (rightmost) command to
# exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully.
set -o pipefail

# Set $IFS to only newline and tab.
#
# http://www.dwheeler.com/essays/filenames-in-shell.html
IFS=$'\n\t'

###############################################################################
# Environment
###############################################################################

# $_ME
#
# This program's basename.
_ME="$(basename "${0}")"

###############################################################################
# Help
###############################################################################

# _print_help()
#
# Usage:
#   _print_help
#
# Print the program help information.
_print_help() {
  cat <<HEREDOC
      _                 _
  ___(_)_ __ ___  _ __ | | ___
 / __| | '_ \` _ \\| '_ \\| |/ _ \\
 \\__ \\ | | | | | | |_) | |  __/
 |___/_|_| |_| |_| .__/|_|\\___|
                 |_|

Boilerplate for creating a simple bash script with some basic strictness
checks and help features.

Usage:
  ${_ME} docker:install  :add docker repository to apt sources
                          then install docker engine
  ${_ME} docker:uninstall:uninstall docker engine
  ${_ME} docker:remove   :removes all images, containers, and volumes
                          (You have to delete any edited configuration files manually)
  ${_ME} shared:deploy   :build and run shared service containers (dns, nginx, mysql, pma, portainer)
  ${_ME} shared:start    :start shared service containers
  ${_ME} shared:stop     :stop shared service containers
  ${_ME} laravel:deploy  :clone your laravel repo, build its assets and configure for production, then start
  ${_ME} laravel:start   :start laravel container
  ${_ME} laravel:stop    :stop laravel container

Options:
  -h --help  Show this screen.
HEREDOC
}

###############################################################################
# Program Functions
###############################################################################

_invalid_argument() {
  printf "Invalid Argument.\\n"
}

_docker_install() {
  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the repository to Apt sources:
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update

  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

_docker_uninstall() {
  sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
}

_docker_remove() {
  sudo rm -rf /var/lib/docker
  sudo rm -rf /var/lib/containerd
}

_shared_deploy() {
  docker compose -f docker-compose-shared.yml up --build -d
}

_shared_start() {
  docker compose -f docker-compose-shared.yml start
}

_shared_stop() {
  docker compose -f docker-compose-shared.yml stop
}

_laravel_build() {
  echo "cloning repository to src folder..."
  git clone -b $GIT_BRANCH $GIT_URL src

  echo "copying entrypoint-builder.sh file to src folder..."
  cp entrypoint-builder.sh src/entrypoint-builder.sh
  chmod +x src/entrypoint-builder.sh

  echo "copying .env file to src folder..."
  cp .env src/.env

  echo "copying entrypoint-laravel.sh file to src folder..."
  cp entrypoint-laravel.sh src/entrypoint-laravel.sh
  chmod +x src/entrypoint-laravel.sh

  docker compose -f docker-compose-builder.yml up --build
  docker compose -f docker-compose-laravel.yml up --build -d

  echo "removing src folder..."
  rm -rf src
}

_laravel_start() {
  docker compose -f docker-compose-laravel.yml start
}

_laravel_stop() {
  docker compose -f docker-compose-laravel.yml stop
}

_test() {
  echo "test..."
}

###############################################################################
# Main
###############################################################################

# _main()
#
# Usage:
#   _main [<options>] [<arguments>]
#
# Description:
#   Entry point for the program, handling basic option parsing and dispatching.
_main() {
  # Avoid complex option parsing when only one program option is expected.
  if [[ "${1:-}" =~ ^-h|--help$ ]]; then
    _print_help
  elif [[ "${1:-}" = "docker:install" ]]; then
    _docker_install
  elif [[ "${1:-}" = "docker:uninstall" ]]; then
    _docker_uninstall
  elif [[ "${1:-}" = "docker:remove" ]]; then
    _docker_remove
  elif [[ "${1:-}" = "shared:deploy" ]]; then
    _shared_deploy
  elif [[ "${1:-}" = "shared:start" ]]; then
    _shared_start
  elif [[ "${1:-}" = "shared:stop" ]]; then
    _shared_stop
  elif [[ "${1:-}" = "laravel:deploy" ]]; then
    _laravel_build
  elif [[ "${1:-}" = "laravel:start" ]]; then
    _laravel_start
  elif [[ "${1:-}" = "laravel:stop" ]]; then
    _laravel_start
  elif [[ "${1:-}" = "test" ]]; then
    _test
  else
    _invalid_argument "$@"
  fi
}

###############################################################################
# Load Env Files
###############################################################################
if [ ! -f ".env" ]; then
  echo "missing .env file"
  exit 1
else
  echo "reading .env file..."
  while read -r LINE; do
    if [[ $LINE == *'='* ]] && [[ $LINE != '#'* ]]; then
      ENV_VAR="$(echo $LINE | envsubst)"
      eval "declare $ENV_VAR"
    fi
  done <.env
fi

# Call `_main` after everything has been defined.
_main "$@"
