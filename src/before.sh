## before hook
##
## Any code here will be placed inside a `before_hook()` function and called
## before running any command (but after processing its arguments).
##
## You can safely delete this file if you do not need it.
#inspect_args

if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root"
   exit 1
fi

#TODO improve here i have duplication in app_env arg and APP_ENV in .env files
#log_header "Reading .env files"
#load_env "env/.env"
#load_env "env/docker.env"

#if [[ -n "${args[APP_ENV]}" ]]; then
#  load_env "env/${args[APP_ENV]}.env"
#fi

#if [[ "$APP_ENV" != "${args[APP_ENV]}" ]]; then
#    log_error "Error: APP_ENV in 'env/${args[APP_ENV]}.env' does not match 'ez' command argument ('$APP_ENV'!='${args[APP_ENV]}')."
#    exit 1
#fi

