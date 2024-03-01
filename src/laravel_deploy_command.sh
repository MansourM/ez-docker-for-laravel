#TODO duplication read APP_ENV from cli args and ignore APP_ENV in .env?
echo -e "\n==[ Preparing to deploy Laravel in $APP_ENV mode ]==\n"

#careful with laravel_folder_name, it must be the same as laravel dockerfile and docker compose file
laravel_folder_name="laravel-$APP_ENV"
#TODO maybe skip if nothing was changed?
# Check if the folder exists
log_header "Preparing source code"
if [ -d "$laravel_folder_name" ]; then
    log "Updating existing $laravel_folder_name folder"

    cd "$laravel_folder_name" || exit 1
    log "Removing previous build folders..."
    rm -rf "node_modules" "vendor" "public/build"
    log "Discarding local changes"
    git reset --hard
    git pull origin "$GIT_BRANCH"

    # Check if the git operation was successful
    if [ $? -ne 0 ]; then
        log_error "Error: Git pull failed."
        exit 1
    fi

    # Check if the directory removal was successful
    if [ $? -ne 0 ]; then
        log_error "Error: Failed to remove build folders."
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

create_new_database_and_user $DB_DATABASE $DB_USERNAME $DB_PASSWORD

log_header "Running Docker Compose for Laravel $APP_ENV"
docker compose -f compose-laravel.yml --profile "$APP_ENV" --env-file "$merged_env" up --build -d
