#TODO duplication read APP_ENV from cli args and ignore APP_ENV in .env?
echo -e "\n==[ Preparing to deploy Laravel in $APP_ENV mode ]==\n"

#careful with laravel_folder_name, it must be the same as laravel dockerfile and docker compose file
laravel_folder_name="laravel-$APP_ENV"

# Check if the folder exists
if [ -d "$laravel_folder_name" ]; then
    echo "==[ Updating existing $laravel_folder_name folder ]=="

    cd "$laravel_folder_name" || exit 1
    echo "Remove previous build folders..."
    rm -rf "node_modules" "vendor" "public/build"
    echo "Discard local changes"
    git reset --hard
    git pull origin "$APP_ENV"

    # Check if the git operation was successful
    if [ $? -ne 0 ]; then
        echo "Error: Git pull failed."
        exit 1
    fi

    # Check if the directory removal was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to remove build folders."
        exit 1
    fi

    cd - || exit 1
else
    echo "==[ Cloning new $laravel_folder_name folder ]=="
    git clone --depth 1 -b "$APP_ENV" "$GIT_URL" "$laravel_folder_name"

    # Check if cloning was successful
    if [ $? -ne 0 ]; then
        echo "Error: Git cloning failed."
        exit 1
    fi
fi

# Copy necessary files to the Laravel folder
env_laravel="env/.env"
entrypoint_laravel="entrypoint/nginx-fpm-laravel.sh"
env_override="env/$APP_ENV.env"
entrypoint_builder="entrypoint/builder-production.sh"
if [[ "$APP_ENV" == "test" ]]; then
    entrypoint_builder="entrypoint/builder-test.sh"
fi

cp "$env_laravel" "$laravel_folder_name/.env"

cp "$entrypoint_builder" "$laravel_folder_name/entrypoint-builder.sh"
chmod +x "$laravel_folder_name/entrypoint-builder.sh"

cp "$entrypoint_laravel" "$laravel_folder_name/entrypoint.sh"
chmod +x "$laravel_folder_name/entrypoint.sh"

# Run Docker Compose
echo -e "\n==[ Running Docker Compose for builder ]==\n"
docker compose -f compose-builder.yml --profile "$APP_ENV" --env-file "$env_laravel" --env-file "$env_override" up --build

echo -e "\n==[ Running Docker Compose for Laravel $APP_ENV ]==\n"
docker compose -f compose-laravel.yml --profile "$APP_ENV" --env-file "$env_laravel" --env-file "$env_override" up --build -d
