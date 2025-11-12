#!/usr/bin/env bash
# Security tests for input validation module

# Set approvals directory before sourcing approvals.bash
TEST_DIR="$(dirname "$0")"
export APPROVALS_DIR="$TEST_DIR/approvals"

source "$TEST_DIR/../approvals.bash"

# Test environment setup
export TEST_MODE=1
PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"
mkdir -p "$TEST_DIR/../tmp"

describe "Input Validation Module Tests"

context "Application Name Validation"
    it "should accept valid application names"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/input_validator.sh\" 2>/dev/null
            validate_app_name \"my-app\" && echo \"my-app: VALID\" || echo \"my-app: INVALID\"
            validate_app_name \"test_app\" && echo \"test_app: VALID\" || echo \"test_app: INVALID\"
            validate_app_name \"app123\" && echo \"app123: VALID\" || echo \"app123: INVALID\"
        ' 2>/dev/null" "app_name_valid"
        
    it "should reject invalid application names"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/input_validator.sh\" 2>/dev/null
            validate_app_name \"my@app\" && echo \"my@app: ACCEPTED\" || echo \"my@app: REJECTED\"
            validate_app_name \"app space\" && echo \"app space: ACCEPTED\" || echo \"app space: REJECTED\"
            validate_app_name \"app;rm -rf\" && echo \"injection: ACCEPTED\" || echo \"injection: REJECTED\"
        ' 2>/dev/null" "app_name_invalid"
        
    it "should reject application names that are too long"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/input_validator.sh\" 2>/dev/null
            long_name=$(printf \"a%.0s\" {1..65})
            validate_app_name \"\$long_name\" && echo \"65 chars: ACCEPTED\" || echo \"65 chars: REJECTED\"
            validate_app_name \"exactly64characterslong123456789012345678901234567890123456\" && echo \"64 chars: ACCEPTED\" || echo \"64 chars: REJECTED\"
        ' 2>/dev/null" "app_name_length"

context "Environment Name Validation"
    it "should accept valid environment names"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/input_validator.sh\" 2>/dev/null
            validate_environment \"dev\" && echo \"dev: VALID\" || echo \"dev: INVALID\"
            validate_environment \"test\" && echo \"test: VALID\" || echo \"test: INVALID\"
            validate_environment \"staging\" && echo \"staging: VALID\" || echo \"staging: INVALID\"
            validate_environment \"production\" && echo \"production: VALID\" || echo \"production: INVALID\"
        ' 2>/dev/null" "env_name_valid"
        
    it "should reject invalid environment names"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/input_validator.sh\" 2>/dev/null
            validate_environment \"prod\" && echo \"prod: ACCEPTED\" || echo \"prod: REJECTED\"
            validate_environment \"development\" && echo \"development: ACCEPTED\" || echo \"development: REJECTED\"
            validate_environment \"local\" && echo \"local: ACCEPTED\" || echo \"local: REJECTED\"
        ' 2>/dev/null" "env_name_invalid"

context "Git URL Validation"
    it "should accept valid Git URLs"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/input_validator.sh\" 2>/dev/null
            validate_git_url \"https://github.com/user/repo.git\" && echo \"https: VALID\" || echo \"https: INVALID\"
            validate_git_url \"http://gitlab.com/user/repo.git\" && echo \"http: VALID\" || echo \"http: INVALID\"
            validate_git_url \"git://github.com/user/repo.git\" && echo \"git: VALID\" || echo \"git: INVALID\"
            validate_git_url \"git@github.com:user/repo.git\" && echo \"ssh: VALID\" || echo \"ssh: INVALID\"
        ' 2>/dev/null" "git_url_valid"
        
    it "should reject invalid Git URLs"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/input_validator.sh\" 2>/dev/null
            validate_git_url \"https://github.com/user/repo\" && echo \"no .git: ACCEPTED\" || echo \"no .git: REJECTED\"
            validate_git_url \"not-a-url\" && echo \"malformed: ACCEPTED\" || echo \"malformed: REJECTED\"
            validate_git_url \"\" && echo \"empty: ACCEPTED\" || echo \"empty: REJECTED\"
        ' 2>/dev/null" "git_url_invalid"

context "Password Sanitization"
    it "should sanitize passwords for bash context"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/input_validator.sh\" 2>/dev/null
            sanitized=\$(sanitize_password \"P@ss#w0rd!\$%\")
            echo \"Sanitized length: \${#sanitized}\"
            echo \"Contains escapes: \$(echo \"\$sanitized\" | grep -o \"\\\\\\\\\" | wc -l)\"
        ' 2>/dev/null" "password_sanitize"

# Cleanup
rm -rf "$TEST_DIR/../tmp/"* 2>/dev/null || true
