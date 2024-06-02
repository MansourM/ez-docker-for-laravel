is_container_running() {
    local container_name=$1
    docker ps --filter "name=$container_name" --filter "status=running" --format '{{.Names}}' | grep -w "$container_name" > /dev/null
    return $?
}