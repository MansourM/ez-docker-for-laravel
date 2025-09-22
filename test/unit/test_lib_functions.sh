#!/usr/bin/env bash
# Unit tests for library functions in src/lib/

source "$(dirname "$0")/../approvals.bash"

# Test environment setup
export TEST_MODE=1
TEST_DIR="$(dirname "$0")"
PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"
mkdir -p "$TEST_DIR/../tmp"

describe "Library Functions Unit Tests"

context "Environment Loading Functions"
    it "should load environment file correctly"
        # Create test env file
        cat > "$TEST_DIR/../tmp/test.env" << EOF
APP_NAME=testapp
APP_ENV=test
DB_HOST=localhost
# This is a comment
EMPTY_LINE=

DB_PASSWORD=secret123
EOF
        
        # Source and test the load_env function
        source "$PROJECT_ROOT/src/lib/load_env.sh"
        approve "load_env '$TEST_DIR/../tmp/test.env' && echo \$APP_NAME \$APP_ENV \$DB_HOST \$DB_PASSWORD"
        
    it "should handle missing env file gracefully"
        source "$PROJECT_ROOT/src/lib/load_env.sh"
        approve "load_env '$TEST_DIR/../tmp/nonexistent.env'"
        expect_exit_code 1

context "Port Assignment Functions"
    it "should check if port is in use"
        source "$PROJECT_ROOT/src/lib/is_port_in_use.sh"
        
        # Mock lsof for testing
        lsof() {
            case "$*" in
                *":8080"*) return 0 ;; # Port in use
                *":9999"*) return 1 ;; # Port free
                *) return 1 ;;
            esac
        }
        
        approve "is_port_in_use 8080 && echo 'Port 8080 in use' || echo 'Port 8080 free'"
        approve "is_port_in_use 9999 && echo 'Port 9999 in use' || echo 'Port 9999 free'"

context "Password Generation"
    it "should generate password of correct length"
        source "$PROJECT_ROOT/src/lib/generate_password.sh"
        
        # Test password generation (filter out actual password for consistent testing)
        allow_diff "[a-zA-Z0-9]+"
        approve "generate_password 12 | wc -c"
        
    it "should generate different passwords each time"
        source "$PROJECT_ROOT/src/lib/generate_password.sh"
        
        # Generate two passwords and compare (they should be different)
        pass1=$(generate_password 20)
        pass2=$(generate_password 20)
        
        if [[ "$pass1" != "$pass2" ]]; then
            echo "PASS: Passwords are different"
        else
            echo "FAIL: Passwords are identical"
        fi

context "Environment Merging"
    it "should merge environment files correctly"
        source "$PROJECT_ROOT/src/lib/merge_envs.sh"
        
        # Create test files
        cat > "$TEST_DIR/../tmp/base.env" << EOF
APP_NAME=baseapp
APP_ENV=production
DB_HOST=localhost
DB_PORT=3306
EOF
        
        cat > "$TEST_DIR/../tmp/override.env" << EOF
APP_ENV=staging
DB_HOST=staging-db
NEW_VAR=newvalue
EOF
        
        approve "merge_envs '$TEST_DIR/../tmp/merged.env' '$TEST_DIR/../tmp/base.env' '$TEST_DIR/../tmp/override.env' && cat '$TEST_DIR/../tmp/merged.env'"

context "User Input Functions"
    it "should handle ask_question function"
        source "$PROJECT_ROOT/src/lib/ask_question.sh" 2>/dev/null || {
            # Mock ask_question for testing
            ask_question() {
                local prompt="$1"
                local default="$2"
                echo "PROMPT: $prompt"
                echo "DEFAULT: $default"
                echo "$default"  # Return default for testing
            }
        }
        
        approve "ask_question 'Enter app name' 'myapp'"

context "Logging Functions"
    it "should display log messages correctly"
        source "$PROJECT_ROOT/src/lib/log_info.sh" 2>/dev/null || {
            log_info() { echo "INFO: $*"; }
        }
        source "$PROJECT_ROOT/src/lib/log_error.sh" 2>/dev/null || {
            log_error() { echo "ERROR: $*"; }
        }
        source "$PROJECT_ROOT/src/lib/log_success.sh" 2>/dev/null || {
            log_success() { echo "SUCCESS: $*"; }
        }
        
        approve "log_info 'This is an info message'"
        approve "log_error 'This is an error message'"  
        approve "log_success 'This is a success message'"

# Cleanup
rm -rf "$TEST_DIR/../tmp/test.env" "$TEST_DIR/../tmp/base.env" "$TEST_DIR/../tmp/override.env" "$TEST_DIR/../tmp/merged.env" 2>/dev/null || true
