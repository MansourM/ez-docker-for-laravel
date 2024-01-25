#inspect_args

#careful with laravel_folder_name, it must be the same as laravel dockerfile and docker compose file
laravel_folder_name="laravel"

# Check if the folder exists
if [ -d "$laravel_folder_name" ]; then
    echo "Updating existing $laravel_folder_name folder..."
    cd "$laravel_folder_name" || exit 1
    git pull origin "$GIT_BRANCH"

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
    git clone --depth 1 -b "$GIT_BRANCH" "$GIT_URL" "$laravel_folder_name"

    # Check if cloning was successful
    if [ $? -ne 0 ]; then
        echo "Error: Git cloning failed."
        exit 1
    fi
fi

# Copy necessary files to the Laravel folder
copy_file ".env" "$laravel_folder_name" ".env"
copy_file "entrypoint-builder.sh" "$laravel_folder_name" "entrypoint-builder.sh"
copy_file "entrypoint-laravel.sh" "$laravel_folder_name" "entrypoint-laravel.sh"


# Run Docker Compose
echo "Running Docker Compose for builder..."
docker compose -f compose-builder.yml up --build

echo "Running Docker Compose for Laravel in detached mode..."
docker compose -f compose-laravel.yml up --build -d
