## before hook
##
## Any code here will be placed inside a `before_hook()` function and called
## before running any command (but after processing its arguments).
##
## You can safely delete this file if you do not need it.
inspect_args

#TODO improve here i have duplication in app_env arg and APP_ENV in .env files
read_env "env/.env"
read_env "env/shared.env"

if [[ -n "${args[APP_ENV]}" ]]; then
  read_env "env/${args[APP_ENV]}.env"
fi

