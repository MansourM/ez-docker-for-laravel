# Log the host in to the image registry, when image mode needs one.
#
# A public registry needs no credentials, so an empty REGISTRY_TOKEN is a valid anonymous pull.
# A half-filled pair is a misconfiguration, and saying so here beats an opaque
# `pull access denied` further down.
registry_login() {
  local registry="$1" user="$2" token="$3"

  if [[ -z "$token" && -z "$user" ]]; then
    log_info "No registry credentials set — assuming an anonymous pull."
    return 0
  fi

  if [[ -z "$token" || -z "$user" ]]; then
    log_error "Registry credentials are half-set: REGISTRY_USER and REGISTRY_TOKEN must both be"
    log_error "present, or both empty for an anonymous pull."
    exit 1
  fi

  if [[ -z "$registry" ]]; then
    log_error "REGISTRY_USER/REGISTRY_TOKEN are set but REGISTRY_HOST is empty."
    log_error "Set REGISTRY_HOST in docker/docker.env (e.g. registry.example.com)."
    exit 1
  fi

  log_info "Logging in to $registry ..."
  if ! printf '%s' "$token" | docker login "$registry" --username "$user" --password-stdin; then
    log_error "docker login to $registry failed for user '$user'."
    log_error "Check REGISTRY_USER / REGISTRY_TOKEN and that the token carries read_registry."
    exit 1
  fi
}
