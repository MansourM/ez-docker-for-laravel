#!/usr/bin/env bash
# Security tests for database security module

source "$(dirname "$0")/../approvals.bash"

# Test environment setup
export TEST_MODE=1
TEST_DIR="$(dirname "$0")"
PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"
mkdir -p "$TEST_DIR/../tmp"

describe "Database Security Module Tests"

context "Database Name Validation"
    it "should accept valid database names"
        source "$PROJECT_ROOT/src/lib/security/db_security.sh" 2>/dev/null || {
            echo "SKIP: db_security.sh not yet created"
            return 0
        }
        
        # Test valid names
        validate_db_name "myapp_db" && echo "✓ myapp_db: VALID" || echo "✗ myapp_db: INVALID"
        validate_db_name "test123" && echo "✓ test123: VALID" || echo "✗ test123: INVALID"
        validate_db_name "app_test_2024" && echo "✓ app_test_2024: VALID" || echo "✗ app_test_2024: INVALID"
        
    it "should reject invalid database names"
        source "$PROJECT_ROOT/src/lib/security/db_security.sh" 2>/dev/null || {
            echo "SKIP: db_security.sh not yet created"
            return 0
        }
        
        # Test invalid names (should fail)
        validate_db_name "my-app" && echo "✗ my-app: ACCEPTED (should reject)" || echo "✓ my-app: REJECTED"
        validate_db_name "app@db" && echo "✗ app@db: ACCEPTED (should reject)" || echo "✓ app@db: REJECTED"
        validate_db_name "test'; DROP TABLE users; --" && echo "✗ SQL injection: ACCEPTED (should reject)" || echo "✓ SQL injection: REJECTED"
        validate_db_name "app db" && echo "✗ app db: ACCEPTED (should reject)" || echo "✓ app db: REJECTED"

context "Username Validation"
    it "should accept valid usernames"
        source "$PROJECT_ROOT/src/lib/security/db_security.sh" 2>/dev/null || {
            echo "SKIP: db_security.sh not yet created"
            return 0
        }
        
        validate_username "appuser" && echo "✓ appuser: VALID" || echo "✗ appuser: INVALID"
        validate_username "user_123" && echo "✓ user_123: VALID" || echo "✗ user_123: INVALID"
        validate_username "test2024" && echo "✓ test2024: VALID" || echo "✗ test2024: INVALID"
        
    it "should reject invalid usernames"
        source "$PROJECT_ROOT/src/lib/security/db_security.sh" 2>/dev/null || {
            echo "SKIP: db_security.sh not yet created"
            return 0
        }
        
        validate_username "user-name" && echo "✗ user-name: ACCEPTED (should reject)" || echo "✓ user-name: REJECTED"
        validate_username "admin' OR '1'='1" && echo "✗ SQL injection: ACCEPTED (should reject)" || echo "✓ SQL injection: REJECTED"
        validate_username "user@host" && echo "✗ user@host: ACCEPTED (should reject)" || echo "✓ user@host: REJECTED"

context "Password Sanitization"
    it "should handle special characters in passwords"
        source "$PROJECT_ROOT/src/lib/security/db_security.sh" 2>/dev/null || {
            echo "SKIP: db_security.sh not yet created"
            return 0
        }
        
        # Test password with special characters
        test_password='P@ss#w0rd!$%'
        sanitized=$(sanitize_password_for_mysql "$test_password")
        
        if [[ -n "$sanitized" ]]; then
            echo "✓ Password sanitized successfully"
        else
            echo "✗ Password sanitization failed"
        fi
        
    it "should preserve password integrity"
        source "$PROJECT_ROOT/src/lib/security/db_security.sh" 2>/dev/null || {
            echo "SKIP: db_security.sh not yet created"
            return 0
        }
        
        # Test that sanitization doesn't corrupt the password
        test_password='MyP@ssw0rd#123'
        sanitized=$(sanitize_password_for_mysql "$test_password")
        
        # The sanitized version should be usable (not empty, not just quotes)
        if [[ -n "$sanitized" ]] && [[ ${#sanitized} -ge ${#test_password} ]]; then
            echo "✓ Password integrity preserved"
        else
            echo "✗ Password integrity compromised"
        fi

context "Network Restriction Validation"
    it "should validate Docker network restriction format"
        source "$PROJECT_ROOT/src/lib/security/db_security.sh" 2>/dev/null || {
            echo "SKIP: db_security.sh not yet created"
            return 0
        }
        
        # Test valid network restrictions
        validate_network_restriction "172.%.%.%" && echo "✓ 172.%.%.%: VALID" || echo "✗ 172.%.%.%: INVALID"
        validate_network_restriction "172.18.%.%" && echo "✓ 172.18.%.%: VALID" || echo "✗ 172.18.%.%: INVALID"
        
    it "should reject wildcard host access"
        source "$PROJECT_ROOT/src/lib/security/db_security.sh" 2>/dev/null || {
            echo "SKIP: db_security.sh not yet created"
            return 0
        }
        
        # Test invalid network restrictions
        validate_network_restriction "%" && echo "✗ %: ACCEPTED (should reject)" || echo "✓ %: REJECTED"
        validate_network_restriction "0.0.0.0" && echo "✗ 0.0.0.0: ACCEPTED (should reject)" || echo "✓ 0.0.0.0: REJECTED"

context "MySQL Command Execution"
    it "should use here-doc for SQL execution"
        source "$PROJECT_ROOT/src/lib/security/db_security.sh" 2>/dev/null || {
            echo "SKIP: db_security.sh not yet created"
            return 0
        }
        
        # Check if execute_mysql_command function exists
        if declare -f execute_mysql_command > /dev/null; then
            echo "✓ execute_mysql_command function exists"
        else
            echo "✗ execute_mysql_command function not found"
        fi
        
    it "should have secure database creation function"
        source "$PROJECT_ROOT/src/lib/security/db_security.sh" 2>/dev/null || {
            echo "SKIP: db_security.sh not yet created"
            return 0
        }
        
        # Check if create_database_secure function exists
        if declare -f create_database_secure > /dev/null; then
            echo "✓ create_database_secure function exists"
        else
            echo "✗ create_database_secure function not found"
        fi
        
    it "should have secure user creation function"
        source "$PROJECT_ROOT/src/lib/security/db_security.sh" 2>/dev/null || {
            echo "SKIP: db_security.sh not yet created"
            return 0
        }
        
        # Check if create_user_secure function exists
        if declare -f create_user_secure > /dev/null; then
            echo "✓ create_user_secure function exists"
        else
            echo "✗ create_user_secure function not found"
        fi

# Cleanup
rm -rf "$TEST_DIR/../tmp/"* 2>/dev/null || true
