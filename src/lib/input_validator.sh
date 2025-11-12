#!/usr/bin/env bash
# Input validation and sanitization functions for security hardening

set -euo pipefail

# Validate application name (alphanumeric, hyphens, underscores only, max 64 chars)
# Args: $1 - application name
# Returns: 0 if valid, 1 if invalid
validate_app_name() {
  local app_name="$1"
  
  # Check for valid characters (alphanumeric, hyphens, underscores)
  if [[ ! "$app_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    if [ "${TEST_MODE:-0}" != "1" ]; then
      echo "[ERROR] Invalid app name: $app_name. Only alphanumeric, hyphens, and underscores allowed." >&2
    fi
    return 1
  fi
  
  # Check length (max 64 characters)
  if [ ${#app_name} -gt 64 ]; then
    if [ "${TEST_MODE:-0}" != "1" ]; then
      echo "[ERROR] App name too long: maximum 64 characters" >&2
    fi
    return 1
  fi
  
  return 0
}

# Validate environment name (restricted to known values)
# Args: $1 - environment name
# Returns: 0 if valid, 1 if invalid
validate_environment() {
  local env="$1"
  
  case "$env" in
    dev|test|staging|production)
      return 0
      ;;
    *)
      if [ "${TEST_MODE:-0}" != "1" ]; then
        echo "[ERROR] Invalid environment: $env. Must be one of: dev, test, staging, production" >&2
      fi
      return 1
      ;;
  esac
}

# Validate Git URL format
# Args: $1 - Git URL
# Returns: 0 if valid, 1 if invalid
validate_git_url() {
  local url="$1"
  
  # Check for empty URL
  if [ -z "$url" ]; then
    if [ "${TEST_MODE:-0}" != "1" ]; then
      echo "[ERROR] Git URL cannot be empty" >&2
    fi
    return 1
  fi
  
  # Check for valid Git URL patterns
  # Supports: https://*.git, http://*.git, git://*.git, git@*:*.git
  if [[ "$url" =~ ^(https?|git)://.*\.git$ ]] || [[ "$url" =~ ^git@.*:.*\.git$ ]]; then
    return 0
  else
    if [ "${TEST_MODE:-0}" != "1" ]; then
      echo "[ERROR] Invalid Git URL format: $url" >&2
      echo "[ERROR] URL must end with .git and use https://, http://, git://, or git@" >&2
    fi
    return 1
  fi
}

# Sanitize password for bash context (escape special characters)
# Args: $1 - password
# Returns: Sanitized password via stdout
sanitize_password() {
  local password="$1"
  
  # Use printf %q for bash-safe quoting
  printf '%q' "$password"
}
