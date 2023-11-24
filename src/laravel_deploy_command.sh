echo "# this file is located in 'src/laravel_deploy_command.sh'"
echo "# code for 'ez laravel deploy' goes here"
echo "# you can edit it freely and regenerate (it will not be overwritten)"
inspect_args

echo "remove existing src folder..."
rm -rf laravel

#echo "cloning repository to laravel folder..."
git clone -b $GIT_BRANCH $GIT_URL laravel

echo "copying entrypoint-builder.sh file to laravel folder..."
cp entrypoint-builder.sh laravel/entrypoint-builder.sh
chmod +x laravel/entrypoint-builder.sh

echo "copying .env file to src folder..."
cp .env laravel/.env

echo "copying entrypoint-laravel.sh file to src folder..."
cp entrypoint-laravel.sh src/entrypoint-laravel.sh
chmod +x src/entrypoint-laravel.sh

docker compose -f docker-compose-builder.yml up --build
docker compose -f docker-compose-laravel.yml up --build -d
