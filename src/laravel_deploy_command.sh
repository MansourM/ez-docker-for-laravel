echo "# this file is located in 'src/laravel_deploy_command.sh'"
echo "# code for 'ez laravel deploy' goes here"
echo "# you can edit it freely and regenerate (it will not be overwritten)"
inspect_args

laravel_folder_name="laravel"
echo "remove existing $laravel_folder_name folder..."
rm -rf $laravel_folder_name

#echo "cloning repository to $laravel_folder_name folder..."
git clone -b $GIT_BRANCH $GIT_URL $laravel_folder_name

echo "copying entrypoint-builder.sh file to $laravel_folder_name folder..."
cp entrypoint-builder.sh $laravel_folder_name/entrypoint-builder.sh
chmod +x $laravel_folder_name/entrypoint-builder.sh

echo "copying .env file to $laravel_folder_name folder..."
cp .env $laravel_folder_name/.env

echo "copying entrypoint-laravel.sh file to $laravel_folder_name folder..."
cp entrypoint-laravel.sh $laravel_folder_name/entrypoint-laravel.sh
chmod +x src/entrypoint-laravel.sh

docker compose -f docker-compose-builder.yml up --build
docker compose -f docker-compose-laravel.yml up --build -d
