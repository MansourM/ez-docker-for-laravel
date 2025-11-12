#!/usr/bin/env bash
# Unit tests for strict error handling

# Set approvals directory before sourcing approvals.bash
TEST_DIR="$(dirname "$0")"
export APPROVALS_DIR="$TEST_DIR/approvals"

source "$TEST_DIR/../approvals.bash"

# Test environment setup
export TEST_MODE=1
PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"
mkdir -p "$TEST_DIR/../tmp"

describe "Error Handling Tests"

context "Global Error Handling (before.sh hook)"
    it "should have set -euo pipefail in before.sh (applies to all commands)"
        approve "grep -q '^set -euo pipefail' '$PROJECT_ROOT/src/before.sh' && echo 'FOUND' || echo 'MISSING'" "before_sh_error_handling"

context "Library Functions Error Handling"
    it "should have proper error handling in db_security.sh"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_db_name \"valid_db\" && echo \"Valid: PASS\" || echo \"Valid: FAIL\"
            validate_db_name \"invalid-db\" && echo \"Invalid: FAIL\" || echo \"Invalid: PASS\"
        ' 2>/dev/null" "db_validation_errors"

context "Error Propagation"
    it "should fail on undefined variables"
        approve "bash -c 'set -euo pipefail; echo \$UNDEFINED_VAR' 2>&1 || echo 'ERROR CAUGHT'" "undefined_var_error"
        
    it "should fail on command errors"
        approve "bash -c 'set -euo pipefail; false && echo \"Should not print\"' 2>&1 || echo 'ERROR CAUGHT'" "command_error"
        
    it "should fail on pipe errors"
        approve "bash -c 'set -euo pipefail; false | true' 2>&1 || echo 'PIPE ERROR CAUGHT'" "pipe_error"

context "Security Module Error Handling"
    it "should return error for empty database name"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_db_name \"\" 2>&1 && echo \"FAIL: Accepted empty\" || echo \"PASS: Rejected empty\"
        ' 2>/dev/null" "empty_db_name"
        
    it "should return error for empty username"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_username \"\" 2>&1 && echo \"FAIL: Accepted empty\" || echo \"PASS: Rejected empty\"
        ' 2>/dev/null" "empty_username"
        
    it "should return error for empty password"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            sanitize_password_for_mysql \"\" 2>&1 && echo \"FAIL: Accepted empty\" || echo \"PASS: Rejected empty\"
        ' 2>/dev/null" "empty_password"

# Cleanup
rm -rf "$TEST_DIR/../tmp/"* 2>/dev/null || true
