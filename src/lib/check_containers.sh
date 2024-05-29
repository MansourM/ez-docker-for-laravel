check_containers() {
    local containers=("$@")

    for container in "${containers[@]}"; do
        if is_container_running "$container"; then
            log_success "Container '$container' is running."
            if is_container_healthy "$container"; then
                log_success "Container '$container' is healthy."
            else
                log_error "Container '$container' is not healthy."
                exit 1
            fi
        else
            log_error "Container '$container' is not running."
            exit 1
        fi
    done
}