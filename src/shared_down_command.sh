#inspect_args

load_env "config/docker.env"

docker compose -f compose-shared.yml --profile "$APP_ENV"  down
