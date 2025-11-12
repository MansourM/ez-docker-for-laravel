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
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_db_name \"myapp_db\" && echo \"myapp_db: VALID\" || echo \"myapp_db: INVALID\"
            validate_db_name \"test123\" && echo \"test123: VALID\" || echo \"test123: INVALID\"
            validate_db_name \"app_test_2024\" && echo \"app_test_2024: VALID\" || echo \"app_test_2024: INVALID\"
        ' 2>/dev/null" "db_name_valid"
        
    it "should reject invalid database names"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_db_name \"my-app\" && echo \"my-app: ACCEPTED\" || echo \"my-app: REJECTED\"
            validate_db_name \"app@db\" && echo \"app@db: ACCEPTED\" || echo \"app@db: REJECTED\"
            validate_db_name \"test'\'''; DROP TABLE users; --\" && echo \"SQL injection: ACCEPTED\" || echo \"SQL injection: REJECTED\"
            validate_db_name \"app db\" && echo \"app db: ACCEPTED\" || echo \"app db: REJECTED\"
        ' 2>/dev/null" "db_name_invalid"

context "Username Validation"
    it "should accept valid usernames"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_username \"appuser\" && echo \"appuser: VALID\" || echo \"appuser: INVALID\"
            validate_username \"user_123\" && echo \"user_123: VALID\" || echo \"user_123: INVALID\"
            validate_username \"test2024\" && echo \"test2024: VALID\" || echo \"test2024: INVALID\"
        ' 2>/dev/null" "username_valid"
        
    it "should reject invalid usernames"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_username \"user-name\" && echo \"user-name: ACCEPTED\" || echo \"user-name: REJECTED\"
            validate_username \"admin'\''  OR '\''1'\''='\''1\" && echo \"SQL injection: ACCEPTED\" || echo \"SQL injection: REJECTED\"
            validate_username \"user@host\" && echo \"user@host: ACCEPTED\" || echo \"user@host: REJECTED\"
        ' 2>/dev/null" "username_invalid"

context "Password Sanitization"
    it "should handle special characters in passwords"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            sanitized=\$(sanitize_password_for_mysql \"P@ss#w0rd!\$%\")
            [[ -n \"\$sanitized\" ]] && echo \"Password sanitized: \${#sanitized} chars\" || echo \"Sanitization failed\"
        ' 2>/dev/null" "password_special_chars"
        
    it "should escape single quotes in passwords"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            original=\"MyP@ss'\''w0rd\"
            sanitized=\$(sanitize_password_for_mysql \"\$original\")
            echo \"Original length: \${#original}\"
            echo \"Sanitized length: \${#sanitized}\"
            echo \"Contains escaped quote: \$(echo \"\$sanitized\" | grep -o \"'\'''\''\" | wc -l)\"
        ' 2>/dev/null" "password_quote_escape"

context "Network Restriction Validation"
    it "should validate Docker network restriction format"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_network_restriction \"172.%.%.%\" && echo \"172.%.%.%: VALID\" || echo \"172.%.%.%: INVALID\"
            validate_network_restriction \"172.18.%.%\" && echo \"172.18.%.%: VALID\" || echo \"172.18.%.%: INVALID\"
        ' 2>/dev/null" "network_valid"
        
    it "should reject wildcard host access"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_network_restriction \"%\" && echo \"%: ACCEPTED\" || echo \"%: REJECTED\"
            validate_network_restriction \"0.0.0.0\" && echo \"0.0.0.0: ACCEPTED\" || echo \"0.0.0.0: REJECTED\"
        ' 2>/dev/null" "network_invalid"

context "Security Functions"
    it "should have all required security functions"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            declare -f execute_mysql_command > /dev/null && echo \"execute_mysql_command: EXISTS\" || echo \"execute_mysql_command: MISSING\"
            declare -f create_database_secure > /dev/null && echo \"create_database_secure: EXISTS\" || echo \"create_database_secure: MISSING\"
            declare -f create_user_secure > /dev/null && echo \"create_user_secure: EXISTS\" || echo \"create_user_secure: MISSING\"
            declare -f update_user_password_secure > /dev/null && echo \"update_user_password_secure: EXISTS\" || echo \"update_user_password_secure: MISSING\"
            declare -f user_exists > /dev/null && echo \"user_exists: EXISTS\" || echo \"user_exists: MISSING\"
            declare -f database_exists > /dev/null && echo \"database_exists: EXISTS\" || echo \"database_exists: MISSING\"
        ' | sort" "security_functions"

# Cleanup
rm -rf "$TEST_DIR/../tmp/"* 2>/dev/null || true
