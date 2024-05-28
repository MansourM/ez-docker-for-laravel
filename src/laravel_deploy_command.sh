inspect_args

log_header "Preparing to deploy Laravel in $APP_ENV mode"

#TODO improve here i have duplication in app_env arg and APP_ENV in .env files
#load_env "env/.env"
#load_env "env/docker.env"

#if [[ -n "${args[APP_ENV]}" ]]; then
#  load_env "env/${args[APP_ENV]}.env"
#fi

#if [[ "$APP_ENV" != "${args[APP_ENV]}" ]]; then
#    log_error "Error: APP_ENV in 'env/${args[APP_ENV]}.env' does not match 'ez' command argument ('$APP_ENV'!='${args[APP_ENV]}')."
#    exit 1
#fi

#careful with laravel_folder_name, it must be the same as laravel dockerfile and docker compose file
laravel_folder_name="laravel-$APP_ENV"
#TODO maybe skip if nothing was changed?
# Check if the folder exists
#TODO add a force clone config somewhere so user can choose to always clone instead of updating the repo
##as updating might potentially not work in some projects
log_header "Preparing source code"
if [ -d "$laravel_folder_name" ]; then
    log "Updating existing $laravel_folder_name folder"

    cd "$laravel_folder_name" || exit 1

    log "Removing previous build folders..."
    rm -rf "node_modules" "vendor" "public/build"
    if [ $? -ne 0 ]; then
        log_error "Error: Failed to remove build folders."
        exit 1
    fi

    log "Discarding local changes"
    git reset --hard
    git pull origin "$GIT_BRANCH"
    if [ $? -ne 0 ]; then
        log_error "Error: Git pull failed."
        exit 1
    fi

    cd - || exit 1
else
    log "Cloning new $laravel_folder_name folder"
    git clone --depth 1 -b "$GIT_BRANCH" "$GIT_URL" "$laravel_folder_name"

    # Check if cloning was successful
    if [ $? -ne 0 ]; then
        log_error "Error: Git cloning failed."
        exit 1
    fi
fi

#TODO check if env files exist?
base_env="env/.env"
override_env="env/$APP_ENV.env"
merged_env="env/merged/$APP_ENV.env"
merge_env $base_env $override_env $merged_env
#TODO merge read_env and merge_env fn and process all env in before.sh?

#FIXME on first run this will fail since db is not fully up and functional yet
create_new_database_and_user $DB_DATABASE $DB_USERNAME $DB_PASSWORD

log_header "Running Docker Compose for Laravel $APP_ENV"
docker compose -f compose-laravel.yml --profile "$APP_ENV" --env-file "$merged_env" up --build -d
