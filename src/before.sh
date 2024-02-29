## before hook
##
## Any code here will be placed inside a `before_hook()` function and called
## before running any command (but after processing its arguments).
##
## You can safely delete this file if you do not need it.
inspect_args

read_env "env/.env"
read_env "env/shared.env"

#TODO improve here i have duplication in app_env arg and APP_ENV in .env files
if [[ -z "${args[APP_ENV]}" ]]; then
        echo "Error: 'APP_ENV' is not set or empty. Please set a valid argument." >&2
        exit 1
fi
read_env "env/${args[APP_ENV]}.env"
