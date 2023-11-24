echo "# this file is located in 'src/shared_start_command.sh'"
echo "# code for 'ez shared start' goes here"
echo "# you can edit it freely and regenerate (it will not be overwritten)"
inspect_args

docker compose -f docker-compose-shared.yml start
