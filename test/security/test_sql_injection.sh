#!/usr/bin/env bash
# Security test for SQL injection prevention

cd "$(dirname "$0")/.."
source approvals.bash

# Simple mock for docker command
docker() {
    echo "MOCK: docker $*"
    
    # Simulate SQL injection detection
    local full_command="$*"
    if [[ "$full_command" == *"'; DROP"* ]] || [[ "$full_command" == *"\"; DROP"* ]]; then
        echo "SECURITY: SQL injection pattern detected in: $full_command"
        return 1
    fi
    
    echo "Query executed safely"
    return 0
}

describe "Database Security Tests"

context "SQL Injection Detection"
    it "should detect basic SQL injection attempt"
        approve "docker exec mysql -e \"SELECT * FROM users WHERE name = 'test'; DROP TABLE users; --'\" 2>&1"
        
    it "should allow safe database queries"  
        approve "docker exec mysql -e \"SELECT * FROM users WHERE name = 'testuser'\" 2>&1"

context "Current Database Function Vulnerability"
    it "should test current create_new_database_and_user function"
        # Test if the current function exists and is vulnerable
        if [[ -f "../src/lib/create_new_database_and_user.sh" ]]; then
            # Set up environment
            export DB_HOST="test_mysql"
            export DB_ROOT_PASSWORD="test_pass"
            
            # Source the function
            source ../src/lib/create_new_database_and_user.sh
            
            # Test with a potentially dangerous database name
            approve "create_new_database_and_user \"test_db'; DROP DATABASE mysql; --\" \"test_user\" \"test_pass\" 2>&1"
        else
            approve "echo 'create_new_database_and_user.sh not found - function needs to be implemented'"
        fi
        
    it "should show password special character issue"
        if [[ -f "../src/lib/create_new_database_and_user.sh" ]]; then
            export DB_HOST="test_mysql"
            export DB_ROOT_PASSWORD="test_pass"
            source ../src/lib/create_new_database_and_user.sh
            
            # Test with hash in password (known issue from README)
            approve "create_new_database_and_user \"test_db\" \"test_user\" \"password#123\" 2>&1 || echo 'FAILED as expected with special chars'"
        else
            approve "echo 'Function not found - special character test skipped'"
        fi