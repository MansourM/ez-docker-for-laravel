log_header "Preparing to deploy Laravel in ${args[APP_ENV]} mode"

app_dir="apps/${args[APP_NAME]}"
if [[ ! -d "$app_dir" ]]; then
    log_error "Directory $app_dir does not exist! you need to setup your app first, try './ez laravel new'"
    exit 1
fi

laravel_env_path="$app_dir/env/laravel.env"
docker_env_path="docker/docker.env"
app_env_path="$app_dir/env/app.env"
override_env_path="$app_dir/env/${args[APP_ENV]}.env"
merged_env_path="$app_dir/env/generated/${args[APP_ENV]}.env"

merge_envs "$merged_env_path" "$laravel_env_path" "$docker_env_path" "$app_env_path" "$override_env_path"

load_env "$docker_env_path"
load_env "$merged_env_path"

SOURCE_CODE_DIR="$app_dir/src-$APP_ENV"
#TODO add a force clone config somewhere so user can choose to always clone instead of updating the repo?
log_info "Preparing source code"
if [ -d "$SOURCE_CODE_DIR" ]; then
    log "Updating existing $SOURCE_CODE_DIR folder"

    cd "$SOURCE_CODE_DIR" || exit 1

    log "Removing previous build folders..."
    rm -rf "node_modules" "vendor" "public/build"
    if [ $? -ne 0 ]; then
        log_error "Error: Failed to remove build folders."
        exit 1
    fi

    log "Discarding local changes"
    git reset --hard
    git remote set-url origin "$GIT_URL"
    git pull origin "$GIT_BRANCH"
    if [ $? -ne 0 ]; then
        log_error "Error: Git pull failed."
        exit 1
    fi

    cd - || exit 1
else
    log "Cloning new $SOURCE_CODE_DIR folder"
    git clone --depth 1 -b "$GIT_BRANCH" "$GIT_URL" "$SOURCE_CODE_DIR"

    # Check if cloning was successful
    if [ $? -ne 0 ]; then
        log_error "Error: Git cloning failed."
        exit 1
    fi
fi

containers=("nginx-pm" "mysql8")
check_containers "${containers[@]}"

create_new_database_and_user "$DB_DATABASE" "$DB_USERNAME" "$DB_PASSWORD"

log_header "Running Docker Compose for Laravel $APP_ENV"
docker compose -f "$app_dir/compose-laravel.yml" --profile "$APP_ENV" --env-file "$merged_env_path" up --build -d
