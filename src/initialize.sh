## initialize hook
##
## Any code here will be placed inside the `initialize()` function and called
## before running anything else.
##
## You can safely delete this file if you do not need it.

read_env "config/.env"

#TODO improve here i have duplication in app_env arg and APP_ENV in .env files
if [[ -z "${args[APP_ENV]}" ]]; then
        echo "Error: 'APP_ENV' is not set or empty. Please set a valid argument." >&2
        exit 1
fi
read_env "config/${args[APP_ENV]}.env"
