#!/usr/bin/env bash
# Unit tests for library functions error handling

# Set approvals directory before sourcing approvals.bash
TEST_DIR="$(dirname "$0")"
export APPROVALS_DIR="$TEST_DIR/approvals"

source "$TEST_DIR/../approvals.bash"

# Test environment setup
export TEST_MODE=1
PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"
mkdir -p "$TEST_DIR/../tmp"

describe "Library Functions Error Handling"

context "Core Library Functions"
    it "should have set -euo pipefail in create_new_database_and_user.sh"
        approve "grep -q '^set -euo pipefail' '$PROJECT_ROOT/src/lib/create_new_database_and_user.sh' && echo 'FOUND' || echo 'MISSING'" "db_user_error_handling"
        
    it "should have set -euo pipefail in setup_environment.sh"
        approve "grep -q '^set -euo pipefail' '$PROJECT_ROOT/src/lib/setup_environment.sh' && echo 'FOUND' || echo 'MISSING'" "setup_env_error_handling"
        
    it "should have set -euo pipefail in load_env.sh"
        approve "grep -q '^set -euo pipefail' '$PROJECT_ROOT/src/lib/load_env.sh' && echo 'FOUND' || echo 'MISSING'" "load_env_error_handling"
        
    it "should have set -euo pipefail in merge_envs.sh"
        approve "grep -q '^set -euo pipefail' '$PROJECT_ROOT/src/lib/merge_envs.sh' && echo 'FOUND' || echo 'MISSING'" "merge_envs_error_handling"

context "Utility Library Functions"
    it "should have set -euo pipefail in assign_port.sh"
        approve "grep -q '^set -euo pipefail' '$PROJECT_ROOT/src/lib/assign_port.sh' && echo 'FOUND' || echo 'MISSING'" "assign_port_error_handling"
        
    it "should have set -euo pipefail in generate_password.sh"
        approve "grep -q '^set -euo pipefail' '$PROJECT_ROOT/src/lib/generate_password.sh' && echo 'FOUND' || echo 'MISSING'" "generate_password_error_handling"
        
    it "should have set -euo pipefail in update_source_code.sh"
        approve "grep -q '^set -euo pipefail' '$PROJECT_ROOT/src/lib/update_source_code.sh' && echo 'FOUND' || echo 'MISSING'" "update_source_error_handling"

# Cleanup
rm -rf "$TEST_DIR/../tmp/"* 2>/dev/null || true
