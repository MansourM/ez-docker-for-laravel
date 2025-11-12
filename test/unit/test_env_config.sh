#!/usr/bin/env bash
# Unit tests for .env configuration loading

source "$(dirname "$0")/../approvals.bash"

# Test environment setup
export TEST_MODE=1
TEST_DIR="$(dirname "$0")"
PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"
mkdir -p "$TEST_DIR/../tmp"

describe "Environment Configuration Tests"

context ".env.example file"
    it "should exist in project root"
        if [[ -f "$PROJECT_ROOT/.env.example" ]]; then
            echo "PASS: .env.example exists"
        else
            echo "FAIL: .env.example not found"
        fi
        
    it "should contain required Docker image versions"
        if [[ -f "$PROJECT_ROOT/.env.example" ]]; then
            grep -q "NGINX_PM_VERSION=" "$PROJECT_ROOT/.env.example" && echo "✓ NGINX_PM_VERSION found" || echo "✗ NGINX_PM_VERSION missing"
            grep -q "MYSQL_VERSION=" "$PROJECT_ROOT/.env.example" && echo "✓ MYSQL_VERSION found" || echo "✗ MYSQL_VERSION missing"
            grep -q "PHPMYADMIN_VERSION=" "$PROJECT_ROOT/.env.example" && echo "✓ PHPMYADMIN_VERSION found" || echo "✗ PHPMYADMIN_VERSION missing"
            grep -q "PORTAINER_VERSION=" "$PROJECT_ROOT/.env.example" && echo "✓ PORTAINER_VERSION found" || echo "✗ PORTAINER_VERSION missing"
        else
            echo "FAIL: .env.example not found"
        fi
        
    it "should contain security settings"
        if [[ -f "$PROJECT_ROOT/.env.example" ]]; then
            grep -q "DB_NETWORK_RESTRICTION=" "$PROJECT_ROOT/.env.example" && echo "✓ DB_NETWORK_RESTRICTION found" || echo "✗ DB_NETWORK_RESTRICTION missing"
            grep -q "MAX_PASSWORD_LENGTH=" "$PROJECT_ROOT/.env.example" && echo "✓ MAX_PASSWORD_LENGTH found" || echo "✗ MAX_PASSWORD_LENGTH missing"
            grep -q "MIN_PASSWORD_LENGTH=" "$PROJECT_ROOT/.env.example" && echo "✓ MIN_PASSWORD_LENGTH found" || echo "✗ MIN_PASSWORD_LENGTH missing"
        else
            echo "FAIL: .env.example not found"
        fi

context "Docker Compose Configuration"
    it "should use environment variables for image versions"
        if [[ -f "$PROJECT_ROOT/docker/common-shared.yml" ]]; then
            grep -q '\${NGINX_PM_VERSION' "$PROJECT_ROOT/docker/common-shared.yml" && echo "✓ NGINX_PM_VERSION variable used" || echo "✗ NGINX_PM_VERSION not used"
            grep -q '\${MYSQL_VERSION' "$PROJECT_ROOT/docker/common-shared.yml" && echo "✓ MYSQL_VERSION variable used" || echo "✗ MYSQL_VERSION not used"
            grep -q '\${PHPMYADMIN_VERSION' "$PROJECT_ROOT/docker/common-shared.yml" && echo "✓ PHPMYADMIN_VERSION variable used" || echo "✗ PHPMYADMIN_VERSION not used"
            grep -q '\${PORTAINER_VERSION' "$PROJECT_ROOT/docker/common-shared.yml" && echo "✓ PORTAINER_VERSION variable used" || echo "✗ PORTAINER_VERSION not used"
        else
            echo "FAIL: docker/common-shared.yml not found"
        fi
        
    it "should not use 'latest' tag for critical services"
        if [[ -f "$PROJECT_ROOT/docker/common-shared.yml" ]]; then
            if grep -q "nginx-proxy-manager:latest" "$PROJECT_ROOT/docker/common-shared.yml"; then
                echo "✗ FAIL: nginx-proxy-manager still uses 'latest' tag"
            else
                echo "✓ PASS: nginx-proxy-manager uses pinned version"
            fi
            
            if grep -q "portainer-ce:latest" "$PROJECT_ROOT/docker/common-shared.yml"; then
                echo "✗ FAIL: portainer still uses 'latest' tag"
            else
                echo "✓ PASS: portainer uses pinned version"
            fi
        else
            echo "FAIL: docker/common-shared.yml not found"
        fi

context "Environment Variable Loading"
    it "should load .env.example variables correctly"
        # Create a test .env file from .env.example
        cp "$PROJECT_ROOT/.env.example" "$TEST_DIR/../tmp/test_security.env"
        
        # Source load_env function
        source "$PROJECT_ROOT/src/lib/load_env.sh"
        
        # Load the test env file
        load_env "$TEST_DIR/../tmp/test_security.env" > /dev/null 2>&1
        
        # Check if variables are loaded
        [[ -n "$NGINX_PM_VERSION" ]] && echo "✓ NGINX_PM_VERSION loaded: $NGINX_PM_VERSION" || echo "✗ NGINX_PM_VERSION not loaded"
        [[ -n "$MYSQL_VERSION" ]] && echo "✓ MYSQL_VERSION loaded: $MYSQL_VERSION" || echo "✗ MYSQL_VERSION not loaded"
        [[ -n "$DB_NETWORK_RESTRICTION" ]] && echo "✓ DB_NETWORK_RESTRICTION loaded: $DB_NETWORK_RESTRICTION" || echo "✗ DB_NETWORK_RESTRICTION not loaded"

context ".gitignore Configuration"
    it "should exclude .env file"
        if [[ -f "$PROJECT_ROOT/.gitignore" ]]; then
            if grep -q "^\.env$" "$PROJECT_ROOT/.gitignore" || grep -q "^\.env\s" "$PROJECT_ROOT/.gitignore"; then
                echo "✓ PASS: .env is in .gitignore"
            else
                echo "✗ FAIL: .env not found in .gitignore"
            fi
        else
            echo "FAIL: .gitignore not found"
        fi

# Cleanup
rm -f "$TEST_DIR/../tmp/test_security.env" 2>/dev/null || true
