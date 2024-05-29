is_container_healthy() {
    local container_name=$1
    local health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name")
    if [ "$health_status" == "healthy" ]; then
        return 0
    else
        return 1
    fi
}