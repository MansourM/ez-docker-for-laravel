#!/usr/bin/env bash
# Integration test for input validation in command files

# Set approvals directory before sourcing approvals.bash
TEST_DIR="$(dirname "$0")"
export APPROVALS_DIR="$TEST_DIR/approvals"

source "$TEST_DIR/../approvals.bash"

PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"

describe "Input Validation Integration Tests"

context "Laravel New Command Validation"
    it "should validate app name in laravel new command"
        # Test that validation functions are available
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\"
            # Test validate_app_name function exists
            type validate_app_name >/dev/null 2>&1 && echo \"validate_app_name: EXISTS\" || echo \"validate_app_name: MISSING\"
            # Test validate_git_url function exists  
            type validate_git_url >/dev/null 2>&1 && echo \"validate_git_url: EXISTS\" || echo \"validate_git_url: MISSING\"
            # Test validate_environment function exists
            type validate_environment >/dev/null 2>&1 && echo \"validate_environment: EXISTS\" || echo \"validate_environment: MISSING\"
        ' 2>/dev/null" "validation_functions_exist"

context "Validation Function Behavior"
    it "should validate app names correctly"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\"
            export TEST_MODE=1
            validate_app_name \"valid-app\" && echo \"valid-app: VALID\" || echo \"valid-app: INVALID\"
            validate_app_name \"invalid@app\" && echo \"invalid@app: VALID\" || echo \"invalid@app: INVALID\"
        ' 2>/dev/null" "app_name_validation"
        
    it "should validate environments correctly"
        approve "bash -c '
            source \"$PROJECT_ROOT/ez\"
            export TEST_MODE=1
            validate_environment \"dev\" && echo \"dev: VALID\" || echo \"dev: INVALID\"
            validate_environment \"invalid\" && echo \"invalid: VALID\" || echo \"invalid: INVALID\"
        ' 2>/dev/null" "environment_validation"

# Cleanup
rm -rf "$TEST_DIR/../tmp/"* 2>/dev/null || true
