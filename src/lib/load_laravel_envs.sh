load_laravel_envs() {
  local app_dir=$1
  local app_env=$2

  docker_env_path="docker/docker.env"
  app_env_path="$app_dir/env/app.env"
  merged_env_path="$app_dir/env/generated/$app_env.env"

  load_env "$docker_env_path"
  load_env "$app_env_path"
  load_env "$merged_env_path"
}
