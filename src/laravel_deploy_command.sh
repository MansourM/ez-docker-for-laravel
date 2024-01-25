#inspect_args

#TODO read APP_ENV from cli args and ignore APP_ENV in .env?
# Check if APP_ENV is set to dev, test, staging, or production
if [[ "$APP_ENV" != "dev" && "$APP_ENV" != "test" && "$APP_ENV" != "staging" && "$APP_ENV" != "production" ]]; then
    echo "Error: Invalid value for APP_ENV. It must be either dev, test, staging, or production."
    exit 1
fi

#careful with laravel_folder_name, it must be the same as laravel dockerfile and docker compose file
laravel_folder_name="laravel-$APP_ENV"

# Check if the folder exists
if [ -d "$laravel_folder_name" ]; then
    echo "Updating existing $laravel_folder_name folder..."
    cd "$laravel_folder_name" || exit 1
    git pull origin "$APP_ENV"

    # Check if the git operation was successful
    if [ $? -ne 0 ]; then
        echo "Error: Git pull failed."
        exit 1
    fi

    echo "Remove previous build folders..."
    rm -rf "node_modules" "vendor" "public/build"

    # Check if the directory removal was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to remove build folders."
        exit 1
    fi

    cd - || exit 1
else
    echo "Cloning new $laravel_folder_name folder..."
    git clone --depth 1 -b "$APP_ENV" "$GIT_URL" "$laravel_folder_name"

    # Check if cloning was successful
    if [ $? -ne 0 ]; then
        echo "Error: Git cloning failed."
        exit 1
    fi
fi

# Copy necessary files to the Laravel folder
#TODO separate .env file for each environment?
copy_file ".env" "$laravel_folder_name" ".env"
copy_file "entrypoint-builder-$APP_ENV.sh" "$laravel_folder_name" "entrypoint-builder.sh"
copy_file "entrypoint-laravel-$APP_ENV.sh" "$laravel_folder_name" "entrypoint-laravel.sh"

# Run Docker Compose
echo "Running Docker Compose for builder..."
docker compose -f compose-builder.yml --profile "$APP_ENV" up --build

echo "Running Docker Compose for Laravel in detached mode..."
docker compose -f compose-laravel.yml --profile "$APP_ENV" up --build -d
