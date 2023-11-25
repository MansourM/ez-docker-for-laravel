#inspect_args

# Check if the network already exists
if docker network inspect "$SHARED_NETWORK_NAME" >/dev/null 2>&1; then
  echo "Network '$SHARED_NETWORK_NAME' already exists"
else
  docker network create "$SHARED_NETWORK_NAME"
  if [ $? -eq 0 ]; then
    echo "Network '$SHARED_NETWORK_NAME' created"
  else
    echo "Failed to create network '$SHARED_NETWORK_NAME'"
    exit 1
  fi
fi

docker compose -f /path/to/docker-compose-shared.yml up --build -d
if [ $? -ne 0 ]; then
  echo "Failed to run Docker Compose"
  exit 1
fi
