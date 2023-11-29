#inspect_args

#careful with laravel_folder_name, it must be the same as laravel dockerfile and docker compose file
laravel_folder_name="laravel"
echo "remove existing $laravel_folder_name folder..."
rm -rf "$laravel_folder_name"

git clone -b "$GIT_BRANCH" "$GIT_URL" "$laravel_folder_name"

# Check if cloning was successful
if [ $? -ne 0 ]; then
    echo "Error: Git cloning failed."
    exit 1
fi

echo "copying entrypoint-builder.sh file to $laravel_folder_name folder..."
if [ -f "entrypoint-builder.sh" ]; then
    cp "entrypoint-builder.sh" "$laravel_folder_name/entrypoint-builder.sh"
    chmod +x "$laravel_folder_name/entrypoint-builder.sh"
else
    echo "Error: entrypoint-builder.sh file not found."
    exit 1
fi

echo "copying .env file to $laravel_folder_name folder..."
if [ -f ".env" ]; then
    cp ".env" "$laravel_folder_name/.env"
else
    echo "Error: .env file not found."
    exit 1
fi

echo "copying entrypoint-laravel.sh file to $laravel_folder_name folder..."
if [ -f "entrypoint-laravel.sh" ]; then
    cp "entrypoint-laravel.sh" "$laravel_folder_name/entrypoint-laravel.sh"
    chmod +x "$laravel_folder_name/entrypoint-laravel.sh"
else
    echo "Error: entrypoint-laravel.sh file not found."
    exit 1
fi

docker compose -f compose-builder.yml up --build
docker compose -f compose-laravel.yml up --build -d
