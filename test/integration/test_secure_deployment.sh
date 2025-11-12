#!/usr/bin/env bash
# Integration test for secure deployment workflow
# Tests the full deployment process with security validations

# Set approvals directory before sourcing approvals.bash
TEST_DIR="$(dirname "$0")"
export APPROVALS_DIR="$TEST_DIR/approvals"

source "$TEST_DIR/../approvals.bash"

PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"
mkdir -p "$TEST_DIR/../tmp"

describe "Secure Deployment Integration Tests"

context "Security Module Integration"
    it "should have all security modules loaded in main CLI"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\"
            
            # Check input validation functions
            type validate_app_name >/dev/null 2>&1 && echo \"validate_app_name: LOADED\" || echo \"validate_app_name: MISSING\"
            type validate_environment >/dev/null 2>&1 && echo \"validate_environment: LOADED\" || echo \"validate_environment: MISSING\"
            type validate_git_url >/dev/null 2>&1 && echo \"validate_git_url: LOADED\" || echo \"validate_git_url: MISSING\"
            
            # Check database security functions
            type validate_db_name >/dev/null 2>&1 && echo \"validate_db_name: LOADED\" || echo \"validate_db_name: MISSING\"
            type validate_username >/dev/null 2>&1 && echo \"validate_username: LOADED\" || echo \"validate_username: MISSING\"
            type sanitize_password_for_mysql >/dev/null 2>&1 && echo \"sanitize_password_for_mysql: LOADED\" || echo \"sanitize_password_for_mysql: MISSING\"
        ' 2>/dev/null" "security_modules_loaded"

context "Input Validation in Deployment Workflow"
    it "should reject invalid app names before deployment"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\"
            export TEST_MODE=1
            
            # Test various invalid app names
            validate_app_name \"app@invalid\" && echo \"app@invalid: ACCEPTED\" || echo \"app@invalid: REJECTED\"
            validate_app_name \"app space\" && echo \"app space: ACCEPTED\" || echo \"app space: REJECTED\"
            validate_app_name \"app;rm-rf\" && echo \"app;rm-rf: ACCEPTED\" || echo \"app;rm-rf: REJECTED\"
            
            # Test valid app name
            validate_app_name \"valid-app-123\" && echo \"valid-app-123: ACCEPTED\" || echo \"valid-app-123: REJECTED\"
        ' 2>/dev/null" "app_name_deployment_validation"
        
    it "should reject invalid environments before deployment"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\"
            export TEST_MODE=1
            
            # Test invalid environments
            validate_environment \"prod\" && echo \"prod: ACCEPTED\" || echo \"prod: REJECTED\"
            validate_environment \"local\" && echo \"local: ACCEPTED\" || echo \"local: REJECTED\"
            validate_environment \"development\" && echo \"development: ACCEPTED\" || echo \"development: REJECTED\"
            
            # Test valid environments
            validate_environment \"dev\" && echo \"dev: ACCEPTED\" || echo \"dev: REJECTED\"
            validate_environment \"test\" && echo \"test: ACCEPTED\" || echo \"test: REJECTED\"
            validate_environment \"staging\" && echo \"staging: ACCEPTED\" || echo \"staging: REJECTED\"
            validate_environment \"production\" && echo \"production: ACCEPTED\" || echo \"production: REJECTED\"
        ' 2>/dev/null" "environment_deployment_validation"

context "Database Security in Deployment"
    it "should validate database credentials before creation"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\"
            export TEST_MODE=1
            
            # Test invalid database names
            validate_db_name \"db-name\" && echo \"db-name: ACCEPTED\" || echo \"db-name: REJECTED\"
            validate_db_name \"db@name\" && echo \"db@name: ACCEPTED\" || echo \"db@name: REJECTED\"
            validate_db_name \"db; DROP TABLE\" && echo \"db; DROP: ACCEPTED\" || echo \"db; DROP: REJECTED\"
            
            # Test valid database name
            validate_db_name \"myapp_dev\" && echo \"myapp_dev: ACCEPTED\" || echo \"myapp_dev: REJECTED\"
        ' 2>/dev/null" "database_name_validation"
        
    it "should validate usernames before user creation"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\"
            export TEST_MODE=1
            
            # Test invalid usernames
            validate_username \"user-name\" && echo \"user-name: ACCEPTED\" || echo \"user-name: REJECTED\"
            validate_username \"user@host\" && echo \"user@host: ACCEPTED\" || echo \"user@host: REJECTED\"
            validate_username \"admin OR 1=1\" && echo \"admin OR 1=1: ACCEPTED\" || echo \"admin OR 1=1: REJECTED\"
            
            # Test valid username
            validate_username \"myapp_user\" && echo \"myapp_user: ACCEPTED\" || echo \"myapp_user: REJECTED\"
        ' 2>/dev/null" "username_validation"
        
    it "should enforce network restrictions for database users"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\"
            export TEST_MODE=1
            
            # Test that wildcard access is rejected
            validate_network_restriction \"%\" && echo \"Wildcard %: ACCEPTED\" || echo \"Wildcard %: REJECTED\"
            validate_network_restriction \"0.0.0.0\" && echo \"0.0.0.0: ACCEPTED\" || echo \"0.0.0.0: REJECTED\"
            
            # Test that Docker network restriction is accepted
            validate_network_restriction \"172.%.%.%\" && echo \"172.%.%.%: ACCEPTED\" || echo \"172.%.%.%: REJECTED\"
            validate_network_restriction \"172.18.%.%\" && echo \"172.18.%.%: ACCEPTED\" || echo \"172.18.%.%: REJECTED\"
        ' 2>/dev/null" "network_restriction_validation"

context "Password Security in Deployment"
    it "should safely handle passwords with special characters"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\"
            export TEST_MODE=1
            
            # Test password sanitization with various special characters
            sanitized=\$(sanitize_password_for_mysql \"P@ssw0rd!\")
            [[ -n \"\$sanitized\" ]] && echo \"P@ssw0rd!: SANITIZED\" || echo \"P@ssw0rd!: FAILED\"
            
            sanitized=\$(sanitize_password_for_mysql \"Pass#\$%^&*123\")
            [[ -n \"\$sanitized\" ]] && echo \"Pass#\$%^&*123: SANITIZED\" || echo \"Pass#\$%^&*123: FAILED\"
            
            sanitized=\$(sanitize_password_for_mysql \"DROP DATABASE test\")
            [[ -n \"\$sanitized\" ]] && echo \"SQL keyword: SANITIZED\" || echo \"SQL keyword: FAILED\"
        ' 2>/dev/null" "password_sanitization"

context "Docker Image Version Pinning"
    it "should use environment variables for Docker image versions"
        approve "bash -c '
            # Check that common-shared.yml uses version variables
            grep -E \"\\$\\{.*VERSION\" \"$PROJECT_ROOT/docker/common-shared.yml\" | sed 's/^[[:space:]]*//' | sort | uniq
        ' 2>/dev/null" "docker_version_variables"
        
    it "should have default versions defined in env example"
        approve "bash -c '
            # Check that .env.example has version definitions
            grep -E \"_VERSION=\" \"$PROJECT_ROOT/.env.example\" | sort
        ' 2>/dev/null" "env_version_defaults"

context "Error Handling in Deployment"
    it "should have strict error handling enabled"
        approve "bash -c '
            # Check that command scripts have set -euo pipefail
            for script in \"$PROJECT_ROOT/src/\"*_command.sh; do
                if grep -q \"set -euo pipefail\" \"\$script\"; then
                    echo \"\$(basename \"\$script\"): HAS_STRICT_MODE\"
                else
                    echo \"\$(basename \"\$script\"): MISSING_STRICT_MODE\"
                fi
            done | sort
        ' 2>/dev/null" "command_error_handling"
        
    it "should have error handling in library functions"
        approve "bash -c '
            # Check key library files for error handling
            for script in \"$PROJECT_ROOT/src/lib/\"*.sh; do
                if grep -q \"set -euo pipefail\" \"\$script\" 2>/dev/null; then
                    echo \"\$(basename \"\$script\"): HAS_STRICT_MODE\"
                else
                    echo \"\$(basename \"\$script\"): NO_STRICT_MODE\"
                fi
            done | sort
        ' 2>/dev/null" "library_error_handling"

context "Security Configuration Files"
    it "should have security headers configuration"
        approve "bash -c '
            if [[ -f \"$PROJECT_ROOT/template/nginx/security-headers.conf\" ]]; then
                echo \"security-headers.conf: EXISTS\"
                # Check for key security headers
                grep -E \"(Strict-Transport-Security|X-Frame-Options|X-Content-Type-Options|Content-Security-Policy)\" \"$PROJECT_ROOT/template/nginx/security-headers.conf\" | wc -l | xargs echo \"Security headers count:\"
            else
                echo \"security-headers.conf: MISSING\"
            fi
        ' 2>/dev/null" "security_headers_config"
        
    it "should have OPcache environment configuration"
        approve "bash -c '
            # Check that opcache.ini uses environment variable
            if grep -q \"OPCACHE_VALIDATE_TIMESTAMPS\" \"$PROJECT_ROOT/template/opcache.ini\" 2>/dev/null; then
                echo \"opcache.ini: USES_ENV_VAR\"
            else
                echo \"opcache.ini: HARDCODED\"
            fi
        ' 2>/dev/null" "opcache_env_config"

context "End-to-End Validation Chain"
    it "should validate complete deployment input chain"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\"
            export TEST_MODE=1
            
            # Simulate a complete validation chain for deployment
            app_name=\"myapp\"
            environment=\"dev\"
            db_name=\"myapp_dev\"
            db_user=\"myapp_dev_user\"
            network=\"172.%.%.%\"
            
            validate_app_name \"\$app_name\" && echo \"1. App name: VALID\" || echo \"1. App name: INVALID\"
            validate_environment \"\$environment\" && echo \"2. Environment: VALID\" || echo \"2. Environment: INVALID\"
            validate_db_name \"\$db_name\" && echo \"3. Database name: VALID\" || echo \"3. Database name: INVALID\"
            validate_username \"\$db_user\" && echo \"4. Username: VALID\" || echo \"4. Username: INVALID\"
            validate_network_restriction \"\$network\" && echo \"5. Network restriction: VALID\" || echo \"5. Network restriction: INVALID\"
            
            echo \"6. Validation chain: COMPLETE\"
        ' 2>/dev/null" "complete_validation_chain"
        
    it "should reject deployment with any invalid input"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\"
            export TEST_MODE=1
            
            # Test that any invalid input breaks the chain
            app_name=\"invalid@app\"
            environment=\"dev\"
            
            if validate_app_name \"\$app_name\"; then
                echo \"Deployment would proceed: SECURITY_RISK\"
            else
                echo \"Deployment blocked by validation: SECURE\"
            fi
            
            # Test with valid app but invalid environment
            app_name=\"validapp\"
            environment=\"prod\"
            
            if validate_app_name \"\$app_name\" && validate_environment \"\$environment\"; then
                echo \"Deployment would proceed: SECURITY_RISK\"
            else
                echo \"Deployment blocked by validation: SECURE\"
            fi
        ' 2>/dev/null" "validation_chain_security"

# Cleanup
rm -rf "$TEST_DIR/../tmp/"* 2>/dev/null || true
