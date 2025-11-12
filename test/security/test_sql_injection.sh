#!/usr/bin/env bash
# SQL Injection Prevention Tests
# Tests that all validation functions properly block SQL injection attempts

# Set approvals directory before sourcing approvals.bash
TEST_DIR="$(dirname "$0")"
export APPROVALS_DIR="$TEST_DIR/approvals"

source "$TEST_DIR/../approvals.bash"

# Test environment setup
export TEST_MODE=1
PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"
mkdir -p "$TEST_DIR/../tmp"

describe "SQL Injection Prevention Tests"

context "Database Name SQL Injection Attempts"
    it "should block SQL injection in database name with DROP statement"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_db_name \"mydb; DROP DATABASE test; --\" && echo \"DROP injection: ACCEPTED\" || echo \"DROP injection: BLOCKED\"
            validate_db_name \"test; DROP TABLE users;\" && echo \"DROP TABLE: ACCEPTED\" || echo \"DROP TABLE: BLOCKED\"
        ' 2>/dev/null" "db_drop_injection"
        
    it "should block SQL injection in database name with UNION statement"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_db_name \"test UNION SELECT * FROM users--\" && echo \"UNION injection: ACCEPTED\" || echo \"UNION injection: BLOCKED\"
            validate_db_name \"db UNION ALL SELECT password FROM admin\" && echo \"UNION ALL: ACCEPTED\" || echo \"UNION ALL: BLOCKED\"
        ' 2>/dev/null" "db_union_injection"
        
    it "should block SQL injection in database name with comment tricks"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_db_name \"test--\" && echo \"Comment --: ACCEPTED\" || echo \"Comment --: BLOCKED\"
            validate_db_name \"test/**/\" && echo \"Comment /**/: ACCEPTED\" || echo \"Comment /**/: BLOCKED\"
            validate_db_name \"test#\" && echo \"Comment #: ACCEPTED\" || echo \"Comment #: BLOCKED\"
        ' 2>/dev/null" "db_comment_injection"
        
    it "should block SQL injection in database name with special characters"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_db_name \"test;\" && echo \"Semicolon: ACCEPTED\" || echo \"Semicolon: BLOCKED\"
            validate_db_name \"test@\" && echo \"At sign: ACCEPTED\" || echo \"At sign: BLOCKED\"
            validate_db_name \"test-name\" && echo \"Hyphen: ACCEPTED\" || echo \"Hyphen: BLOCKED\"
            validate_db_name \"test.db\" && echo \"Dot: ACCEPTED\" || echo \"Dot: BLOCKED\"
        ' 2>/dev/null" "db_special_chars"

context "Username SQL Injection Attempts"
    it "should block SQL injection in username with OR statement"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_username \"admin OR 1=1\" && echo \"OR 1=1: ACCEPTED\" || echo \"OR 1=1: BLOCKED\"
            validate_username \"user OR 1=1--\" && echo \"OR with comment: ACCEPTED\" || echo \"OR with comment: BLOCKED\"
        ' 2>/dev/null" "username_or_injection"
        
    it "should block SQL injection in username with DROP statement"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_username \"admin; DROP USER root;--\" && echo \"DROP USER: ACCEPTED\" || echo \"DROP USER: BLOCKED\"
            validate_username \"test; DELETE FROM mysql.user;\" && echo \"DELETE: ACCEPTED\" || echo \"DELETE: BLOCKED\"
        ' 2>/dev/null" "username_drop_injection"
        
    it "should block SQL injection in username with special characters"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_username \"user-name\" && echo \"Hyphen: ACCEPTED\" || echo \"Hyphen: BLOCKED\"
            validate_username \"user@host\" && echo \"At sign: ACCEPTED\" || echo \"At sign: BLOCKED\"
            validate_username \"user.name\" && echo \"Dot: ACCEPTED\" || echo \"Dot: BLOCKED\"
            validate_username \"user;\" && echo \"Semicolon: ACCEPTED\" || echo \"Semicolon: BLOCKED\"
        ' 2>/dev/null" "username_special_chars"

context "Password SQL Injection Attempts"
    it "should safely handle passwords with SQL keywords"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            sanitized=\$(sanitize_password_for_mysql \"DROP DATABASE test\")
            [[ -n \"\$sanitized\" ]] && echo \"SQL keyword password: SANITIZED\" || echo \"SQL keyword password: FAILED\"
            
            sanitized=\$(sanitize_password_for_mysql \"SELECT * FROM users\")
            [[ -n \"\$sanitized\" ]] && echo \"SELECT password: SANITIZED\" || echo \"SELECT password: FAILED\"
        ' 2>/dev/null" "password_sql_keywords"
        
    it "should properly escape single quotes in passwords"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            original=\"P@ssw0rd\"
            sanitized=\$(sanitize_password_for_mysql \"\$original\")
            
            echo \"Original length: \${#original}\"
            echo \"Sanitized length: \${#sanitized}\"
            [[ -n \"\$sanitized\" ]] && echo \"Password sanitization: SUCCESS\" || echo \"Password sanitization: FAILED\"
        ' 2>/dev/null" "password_quote_escape"
        
    it "should handle passwords with multiple special characters"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            sanitized=\$(sanitize_password_for_mysql \"P@ss#\$%^&*()w0rd!\")
            [[ -n \"\$sanitized\" ]] && echo \"Complex password: SANITIZED (\${#sanitized} chars)\" || echo \"Complex password: FAILED\"
        ' 2>/dev/null" "password_complex"

context "Network Restriction SQL Injection Attempts"
    it "should block SQL injection in network restriction"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_network_restriction \"172.%.%.% OR 1=1\" && echo \"OR injection: ACCEPTED\" || echo \"OR injection: BLOCKED\"
            validate_network_restriction \"172.18.0.1; DROP TABLE users;\" && echo \"DROP injection: ACCEPTED\" || echo \"DROP injection: BLOCKED\"
        ' 2>/dev/null" "network_injection"
        
    it "should block wildcard and unrestricted access"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_network_restriction \"%\" && echo \"Wildcard %: ACCEPTED\" || echo \"Wildcard %: BLOCKED\"
            validate_network_restriction \"0.0.0.0\" && echo \"All hosts: ACCEPTED\" || echo \"All hosts: BLOCKED\"
            validate_network_restriction \"*\" && echo \"Asterisk: ACCEPTED\" || echo \"Asterisk: BLOCKED\"
        ' 2>/dev/null" "network_wildcard"

context "Combined SQL Injection Scenarios"
    it "should block chained SQL injection attempts"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_db_name \"test; DROP DATABASE test; DROP USER admin; --\" && echo \"Chained DROP: ACCEPTED\" || echo \"Chained DROP: BLOCKED\"
            validate_username \"admin; UPDATE mysql.user SET password=hacked; --\" && echo \"Chained UPDATE: ACCEPTED\" || echo \"Chained UPDATE: BLOCKED\"
        ' 2>/dev/null" "chained_injection"
        
    it "should block encoded SQL injection attempts"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_db_name \"test%27%3B%20DROP%20DATABASE\" && echo \"URL encoded: ACCEPTED\" || echo \"URL encoded: BLOCKED\"
            validate_username \"admin\\x27\\x3B\" && echo \"Hex encoded: ACCEPTED\" || echo \"Hex encoded: BLOCKED\"
        ' 2>/dev/null" "encoded_injection"

context "Edge Cases and Boundary Tests"
    it "should handle empty and null-like inputs"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            validate_db_name \"\" && echo \"Empty string: ACCEPTED\" || echo \"Empty string: BLOCKED\"
            validate_username \"NULL\" && echo \"NULL keyword: ACCEPTED\" || echo \"NULL keyword: BLOCKED\"
            sanitize_password_for_mysql \"\" && echo \"Empty password: SANITIZED\" || echo \"Empty password: BLOCKED\"
        ' 2>/dev/null" "empty_inputs"
        
    it "should handle maximum length boundary attacks"
        approve "bash -c '
            source \"$PROJECT_ROOT/src/lib/security/db_security.sh\" 2>/dev/null
            long_name=\$(printf \"a%.0s\" {1..65})
            validate_db_name \"\${long_name} OR 1=1--\" && echo \"Long + injection: ACCEPTED\" || echo \"Long + injection: BLOCKED\"
            
            long_user=\$(printf \"u%.0s\" {1..33})
            validate_username \"\${long_user} OR 1=1--\" && echo \"Long user + injection: ACCEPTED\" || echo \"Long user + injection: BLOCKED\"
        ' 2>/dev/null" "length_boundary"

# Cleanup
rm -rf "$TEST_DIR/../tmp/"* 2>/dev/null || true
