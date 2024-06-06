check_containers() {
    log_header "Checking shared containers health before building the Laravel container."
    local containers=("$@")
    local retries=4
    local delay=10

    for container in "${containers[@]}"; do
        for attempt in $(seq 1 $((retries + 1))); do
            if is_container_running "$container"; then
                log_success "Container '$container' is running."
                if is_container_healthy "$container"; then
                    log_success "Container '$container' is healthy."
                    break
                else
                    log_warning "Container '$container' is not healthy. Attempt $((attempt))/$retries."
                fi
            else
                log_warning "Container '$container' is not running. Attempt $((attempt))/$retries. You can run shared container by './ez shared deploy'"
            fi

            if [ $attempt -gt $retries ]; then
                log_error "Container '$container' is not healthy or not running after $retries attempts."
                exit 1
            fi

            log_info "Retrying in $delay seconds: "
            for ((i=0; i<$delay; i++)); do
                echo -n "."
                sleep 1
            done
            echo ""
        done
    done
}
