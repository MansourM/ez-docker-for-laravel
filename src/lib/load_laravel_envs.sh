load_laravel_envs() {
  local app_dir=$1
  local app_env=$2

  laravel_env_path="$app_dir/env/laravel.env"
  docker_env_path="docker/docker.env"
  app_env_path="$app_dir/env/app.env"
  override_env_path="$app_dir/env/$app_env.env"
  merged_env_path="$app_dir/env/generated/$app_env.env"

  merge_envs "$merged_env_path" "$laravel_env_path" "$docker_env_path" "$app_env_path" "$override_env_path"

  load_env "$docker_env_path"
  load_env "$app_env_path"
  load_env "$merged_env_path"

  echo "$merged_env_path"
}
