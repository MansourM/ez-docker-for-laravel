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
        approve "test -f '$PROJECT_ROOT/.env.example' && echo '.env.example exists' || echo '.env.example not found'"
        
    it "should contain required Docker image versions"
        approve "grep 'NGINX_PM_VERSION=\|MYSQL_VERSION=\|PHPMYADMIN_VERSION=\|PORTAINER_VERSION=' '$PROJECT_ROOT/.env.example' | sort"
        
    it "should contain security settings"
        approve "grep 'DB_NETWORK_RESTRICTION=\|MAX_PASSWORD_LENGTH=\|MIN_PASSWORD_LENGTH=' '$PROJECT_ROOT/.env.example' | sort"

context "Docker Compose Configuration"
    it "should use environment variables for image versions"
        approve "grep '\${NGINX_PM_VERSION\|\${MYSQL_VERSION\|\${PHPMYADMIN_VERSION\|\${PORTAINER_VERSION' '$PROJECT_ROOT/docker/common-shared.yml' | grep -v '#'"
        
    it "should not use 'latest' tag for critical services"
        approve "grep -E 'nginx-proxy-manager:|portainer-ce:|mysql:|phpmyadmin:' '$PROJECT_ROOT/docker/common-shared.yml' | grep -v '#' | sort"

context "Environment Variable Loading"
    it "should load .env.example variables correctly"
        # Create test script that loads env and outputs variables
        approve "bash -c '
            log() { :; }
            export -f log
            source \"$PROJECT_ROOT/src/lib/load_env.sh\"
            load_env \"$PROJECT_ROOT/.env.example\" > /dev/null 2>&1
            echo \"NGINX_PM_VERSION=\$NGINX_PM_VERSION\"
            echo \"MYSQL_VERSION=\$MYSQL_VERSION\"
            echo \"DB_NETWORK_RESTRICTION=\$DB_NETWORK_RESTRICTION\"
        ' | sort" "env_var_loading"

context ".gitignore Configuration"
    it "should exclude .env file"
        approve "grep -E '^\.env$|^\.env[[:space:]]' '$PROJECT_ROOT/.gitignore' || echo '.env not in .gitignore'"

# Cleanup
rm -f "$TEST_DIR/../tmp/test_security.env" 2>/dev/null || true
