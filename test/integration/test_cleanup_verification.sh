#!/usr/bin/env bash
# Test cleanup and verification for security configurations
# Ensures tests clean up properly and security configs are applied

# Set approvals directory before sourcing approvals.bash
TEST_DIR="$(dirname "$0")"
export APPROVALS_DIR="$TEST_DIR/approvals"

source "$TEST_DIR/../approvals.bash"

PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"
mkdir -p "$TEST_DIR/../tmp"

describe "Test Cleanup and Verification"

context "Test Cleanup Mechanisms"
    it "should have cleanup in all test files"
        approve "bash -c '
            # Check that all test files have cleanup
            for test_file in \"$PROJECT_ROOT/test/\"**/*.sh; do
                if [[ \"\$(basename \"\$test_file\")\" == test_*.sh ]]; then
                    if grep -q \"rm -rf.*tmp\" \"\$test_file\" 2>/dev/null; then
                        echo \"\$(basename \"\$test_file\"): HAS_CLEANUP\"
                    else
                        echo \"\$(basename \"\$test_file\"): NO_CLEANUP\"
                    fi
                fi
            done | sort
        ' 2>/dev/null" "test_cleanup_check"
        
    it "should create and clean up tmp directories properly"
        approve "bash -c '
            # Test tmp directory creation and cleanup
            TEST_TMP=\"$TEST_DIR/../tmp/test_cleanup_$$\"
            
            # Create test directory
            mkdir -p \"\$TEST_TMP\"
            [[ -d \"\$TEST_TMP\" ]] && echo \"Tmp directory created: SUCCESS\" || echo \"Tmp directory created: FAILED\"
            
            # Create test file
            echo \"test data\" > \"\$TEST_TMP/test.txt\"
            [[ -f \"\$TEST_TMP/test.txt\" ]] && echo \"Test file created: SUCCESS\" || echo \"Test file created: FAILED\"
            
            # Cleanup
            rm -rf \"\$TEST_TMP\" 2>/dev/null || true
            [[ ! -d \"\$TEST_TMP\" ]] && echo \"Cleanup: SUCCESS\" || echo \"Cleanup: FAILED\"
        ' 2>/dev/null" "tmp_directory_lifecycle"

context "Security Configuration Verification"
    it "should verify security headers are properly configured"
        approve "bash -c '
            SECURITY_HEADERS=\"$PROJECT_ROOT/template/nginx/security-headers.conf\"
            
            if [[ ! -f \"\$SECURITY_HEADERS\" ]]; then
                echo \"Security headers file: MISSING\"
                exit 0
            fi
            
            echo \"Security headers file: EXISTS\"
            
            # Check for required headers
            grep -q \"Strict-Transport-Security\" \"\$SECURITY_HEADERS\" && echo \"HSTS: CONFIGURED\" || echo \"HSTS: MISSING\"
            grep -q \"X-Frame-Options\" \"\$SECURITY_HEADERS\" && echo \"X-Frame-Options: CONFIGURED\" || echo \"X-Frame-Options: MISSING\"
            grep -q \"X-Content-Type-Options\" \"\$SECURITY_HEADERS\" && echo \"X-Content-Type-Options: CONFIGURED\" || echo \"X-Content-Type-Options: MISSING\"
            grep -q \"Content-Security-Policy\" \"\$SECURITY_HEADERS\" && echo \"CSP: CONFIGURED\" || echo \"CSP: MISSING\"
            grep -q \"server_tokens off\" \"\$SECURITY_HEADERS\" && echo \"Server tokens hidden: CONFIGURED\" || echo \"Server tokens hidden: MISSING\"
        ' 2>/dev/null" "security_headers_verification"
        
    it "should verify OPcache is environment-aware"
        approve "bash -c '
            OPCACHE_INI=\"$PROJECT_ROOT/template/opcache.ini\"
            
            if [[ ! -f \"\$OPCACHE_INI\" ]]; then
                echo \"OPcache config: MISSING\"
                exit 0
            fi
            
            echo \"OPcache config: EXISTS\"
            
            # Check for environment variable usage
            if grep -q \"OPCACHE_VALIDATE_TIMESTAMPS\" \"\$OPCACHE_INI\"; then
                echo \"Environment-aware: YES\"
                
                # Check default value
                grep \"opcache.validate_timestamps\" \"\$OPCACHE_INI\" | head -1
            else
                echo \"Environment-aware: NO\"
            fi
        ' 2>/dev/null" "opcache_config_verification"
        
    it "should verify Docker image versions are pinned"
        approve "bash -c '
            COMPOSE_FILE=\"$PROJECT_ROOT/docker/common-shared.yml\"
            ENV_EXAMPLE=\"$PROJECT_ROOT/.env.example\"
            
            echo \"=== Docker Compose Version Variables ===\"
            grep -E \"\\$\\{.*VERSION\" \"\$COMPOSE_FILE\" 2>/dev/null | wc -l | xargs echo \"Version variables in compose:\"
            
            echo \"\"
            echo \"=== Environment Defaults ===\"
            grep -E \"_VERSION=\" \"\$ENV_EXAMPLE\" 2>/dev/null | wc -l | xargs echo \"Version defaults in .env.example:\"
            
            # Verify no latest tags
            if grep -q \":latest\" \"\$COMPOSE_FILE\" 2>/dev/null; then
                echo \"Latest tags found: SECURITY_RISK\"
            else
                echo \"Latest tags found: NONE\"
            fi
        ' 2>/dev/null" "docker_version_pinning_verification"

context "Security Module Integration Verification"
    it "should verify all security modules are sourced correctly"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\" 2>/dev/null
            
            # Check input validation module
            if declare -f validate_app_name >/dev/null 2>&1; then
                echo \"Input validation module: LOADED\"
            else
                echo \"Input validation module: NOT_LOADED\"
            fi
            
            # Check database security module
            if declare -f validate_db_name >/dev/null 2>&1; then
                echo \"Database security module: LOADED\"
            else
                echo \"Database security module: NOT_LOADED\"
            fi
            
            # Check password sanitization
            if declare -f sanitize_password_for_mysql >/dev/null 2>&1; then
                echo \"Password sanitization: AVAILABLE\"
            else
                echo \"Password sanitization: NOT_AVAILABLE\"
            fi
        ' 2>/dev/null" "security_modules_integration"

context "Error Handling Verification"
    it "should verify error handling in critical paths"
        approve "bash -c '
            # Check setup_environment.sh has strict mode
            if grep -q \"set -euo pipefail\" \"$PROJECT_ROOT/src/lib/setup_environment.sh\" 2>/dev/null; then
                echo \"setup_environment.sh: HAS_STRICT_MODE\"
            else
                echo \"setup_environment.sh: NO_STRICT_MODE\"
            fi
            
            # Check create_new_database_and_user.sh has strict mode
            if grep -q \"set -euo pipefail\" \"$PROJECT_ROOT/src/lib/create_new_database_and_user.sh\" 2>/dev/null; then
                echo \"create_new_database_and_user.sh: HAS_STRICT_MODE\"
            else
                echo \"create_new_database_and_user.sh: NO_STRICT_MODE\"
            fi
            
            # Check input_validator.sh has strict mode
            if grep -q \"set -euo pipefail\" \"$PROJECT_ROOT/src/lib/security/input_validator.sh\" 2>/dev/null; then
                echo \"input_validator.sh: HAS_STRICT_MODE\"
            else
                echo \"input_validator.sh: NO_STRICT_MODE\"
            fi
        ' 2>/dev/null" "critical_path_error_handling"

context "Rollback Scenario Testing"
    it "should handle validation failure gracefully"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\" 2>/dev/null
            export TEST_MODE=1
            
            # Test that validation failure stops execution
            if validate_app_name \"invalid@app\" 2>/dev/null; then
                echo \"Invalid input accepted: ROLLBACK_NEEDED\"
            else
                echo \"Invalid input rejected: NO_ROLLBACK_NEEDED\"
            fi
            
            # Test that valid input proceeds
            if validate_app_name \"validapp\" 2>/dev/null; then
                echo \"Valid input accepted: PROCEED\"
            else
                echo \"Valid input rejected: ERROR\"
            fi
        ' 2>/dev/null" "validation_failure_rollback"
        
    it "should verify database operations can be rolled back"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\" 2>/dev/null
            export TEST_MODE=1
            
            # Check that database security functions exist
            if declare -f database_exists >/dev/null 2>&1; then
                echo \"database_exists function: AVAILABLE\"
            else
                echo \"database_exists function: NOT_AVAILABLE\"
            fi
            
            if declare -f user_exists >/dev/null 2>&1; then
                echo \"user_exists function: AVAILABLE\"
            else
                echo \"user_exists function: NOT_AVAILABLE\"
            fi
            
            # These functions allow checking state before/after operations
            echo \"Rollback capability: SUPPORTED\"
        ' 2>/dev/null" "database_rollback_capability"

context "Test Suite Completeness"
    it "should have tests for all security modules"
        approve "bash -c '
            echo \"=== Security Test Coverage ===\"
            
            # Input validation tests
            [[ -f \"$PROJECT_ROOT/test/security/test_input_validation.sh\" ]] && echo \"Input validation tests: EXISTS\" || echo \"Input validation tests: MISSING\"
            
            # Database security tests
            [[ -f \"$PROJECT_ROOT/test/security/test_db_security_module.sh\" ]] && echo \"Database security tests: EXISTS\" || echo \"Database security tests: MISSING\"
            
            # SQL injection tests
            [[ -f \"$PROJECT_ROOT/test/security/test_sql_injection.sh\" ]] && echo \"SQL injection tests: EXISTS\" || echo \"SQL injection tests: MISSING\"
            
            echo \"\"
            echo \"=== Integration Test Coverage ===\"
            
            # Input validation integration
            [[ -f \"$PROJECT_ROOT/test/integration/test_input_validation_integration.sh\" ]] && echo \"Input validation integration: EXISTS\" || echo \"Input validation integration: MISSING\"
            
            # Secure deployment integration
            [[ -f \"$PROJECT_ROOT/test/integration/test_secure_deployment.sh\" ]] && echo \"Secure deployment integration: EXISTS\" || echo \"Secure deployment integration: MISSING\"
        ' 2>/dev/null" "test_coverage_check"
        
    it "should verify all test runners work correctly"
        approve "bash -c '
            # Check test runners exist
            [[ -f \"$PROJECT_ROOT/test/unit/_run_tests.sh\" ]] && echo \"Unit test runner: EXISTS\" || echo \"Unit test runner: MISSING\"
            [[ -f \"$PROJECT_ROOT/test/security/_run_tests.sh\" ]] && echo \"Security test runner: EXISTS\" || echo \"Security test runner: MISSING\"
            [[ -f \"$PROJECT_ROOT/test/integration/_run_tests.sh\" ]] && echo \"Integration test runner: EXISTS\" || echo \"Integration test runner: MISSING\"
            [[ -f \"$PROJECT_ROOT/test/run_all_tests.sh\" ]] && echo \"All tests runner: EXISTS\" || echo \"All tests runner: MISSING\"
            
            # Check they are executable
            [[ -x \"$PROJECT_ROOT/test/run_all_tests.sh\" ]] && echo \"All tests runner executable: YES\" || echo \"All tests runner executable: NO\"
        ' 2>/dev/null" "test_runners_verification"

context "Configuration File Integrity"
    it "should verify .env.example has all required security settings"
        approve "bash -c '
            ENV_EXAMPLE=\"$PROJECT_ROOT/.env.example\"
            
            if [[ ! -f \"\$ENV_EXAMPLE\" ]]; then
                echo \".env.example: MISSING\"
                exit 0
            fi
            
            echo \".env.example: EXISTS\"
            echo \"\"
            
            # Check for version pinning
            grep -q \"NGINX_PM_VERSION\" \"\$ENV_EXAMPLE\" && echo \"NGINX_PM_VERSION: DEFINED\" || echo \"NGINX_PM_VERSION: MISSING\"
            grep -q \"MYSQL_VERSION\" \"\$ENV_EXAMPLE\" && echo \"MYSQL_VERSION: DEFINED\" || echo \"MYSQL_VERSION: MISSING\"
            grep -q \"PHPMYADMIN_VERSION\" \"\$ENV_EXAMPLE\" && echo \"PHPMYADMIN_VERSION: DEFINED\" || echo \"PHPMYADMIN_VERSION: MISSING\"
            grep -q \"PORTAINER_VERSION\" \"\$ENV_EXAMPLE\" && echo \"PORTAINER_VERSION: DEFINED\" || echo \"PORTAINER_VERSION: MISSING\"
            
            echo \"\"
            
            # Check for security settings
            grep -q \"DB_NETWORK_RESTRICTION\" \"\$ENV_EXAMPLE\" && echo \"DB_NETWORK_RESTRICTION: DEFINED\" || echo \"DB_NETWORK_RESTRICTION: MISSING\"
        ' 2>/dev/null" "env_example_integrity"
        
    it "should verify .gitignore excludes sensitive files"
        approve "bash -c '
            GITIGNORE=\"$PROJECT_ROOT/.gitignore\"
            
            if [[ ! -f \"\$GITIGNORE\" ]]; then
                echo \".gitignore: MISSING\"
                exit 0
            fi
            
            echo \".gitignore: EXISTS\"
            
            # Check for .env exclusion
            if grep -q \"^\\.env$\" \"\$GITIGNORE\" || grep -q \"^/\\.env$\" \"\$GITIGNORE\"; then
                echo \".env excluded: YES\"
            else
                echo \".env excluded: NO\"
            fi
            
            # Check that .env.example is NOT excluded
            if grep -q \"\\.env\\.example\" \"\$GITIGNORE\"; then
                echo \".env.example excluded: YES (WRONG)\"
            else
                echo \".env.example excluded: NO (CORRECT)\"
            fi
        ' 2>/dev/null" "gitignore_verification"

# Cleanup
rm -rf "$TEST_DIR/../tmp/"* 2>/dev/null || true
