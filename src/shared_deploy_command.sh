echo "# this file is located in 'src/shared_deploy_command.sh'"
echo "# code for 'ez shared deploy' goes here"
echo "# you can edit it freely and regenerate (it will not be overwritten)"
inspect_args

# Check if the network already exists
if docker network inspect "$SHARED_NETWORK_NAME" >/dev/null 2>&1; then
  echo "Network '$SHARED_NETWORK_NAME' already exists"
else
  # Create the network
  docker network create "$SHARED_NETWORK_NAME"
  echo "Network '$SHARED_NETWORK_NAME' created"
fi
docker compose -f docker-compose-shared.yml up --build -d
