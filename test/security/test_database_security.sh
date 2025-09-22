#!/usr/bin/env bash
# Security tests for database operations
# Tests for SQL injection prevention and input validation

source "$(dirname "$0")/../approvals.bash"

# Set up test environment
export TEST_MODE=1
export DB_HOST="test_mysql"
export DB_ROOT_PASSWORD="test_root_pass"

# Mock docker exec for testing
docker() {
    if [[ "$1" == "exec" && "$3" == "mysql" ]]; then
        # Simulate different scenarios based on input
        local query=""
        for arg in "$@"; do
            if [[ "$arg" == *"SELECT COUNT"* ]]; then
                query="$arg"
                break
            elif [[ "$arg" == *"CREATE DATABASE"* ]]; then
                query="$arg"
                break
            elif [[ "$arg" == *"CREATE USER"* ]]; then
                query="$arg"
                break
            fi
        done
        
        echo "MOCK MYSQL EXEC: $query"
        
        # Simulate SQL injection attempts
        if [[ "$query" == *"'; DROP"* ]] || [[ "$query" == *"\`; DROP"* ]]; then
            echo "ERROR: SQL injection detected!"
            return 1
        fi
        
        # Simulate normal responses
        if [[ "$query" == *"SELECT COUNT"* ]]; then
            echo "0"  # Database doesn't exist
        else
            echo "Query OK"
        fi
        return 0
    else
        echo "MOCK DOCKER: $*"
        return 0
    fi
}

# Set up paths
TEST_DIR="$(dirname "$0")"
PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"

# Source the function we're testing
source "$PROJECT_ROOT/src/lib/create_new_database_and_user.sh" 2>/dev/null || {
    # Create a test version of the function
    create_new_database_and_user() {
        if [ "$#" -ne 3 ]; then
            echo "Invalid Arguments, Usage: $0 <new_db_name> <new_user_name> <new_user_password>"
            return 1
        fi
        
        local NEW_DB_NAME=$1
        local NEW_USER_NAME=$2
        local NEW_USER_PASSWORD=$3
        
        echo "Creating Database: $NEW_DB_NAME with User: $NEW_USER_NAME"
        
        # This is the VULNERABLE version we need to fix
        # It's susceptible to SQL injection
        docker exec -i "$DB_HOST" mysql -u"root" -p"$DB_ROOT_PASSWORD" -e \
            "SELECT COUNT(*) FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$NEW_DB_NAME';" --skip-column-names 2>/dev/null
            
        docker exec -i "$DB_HOST" mysql -u"root" -p"$DB_ROOT_PASSWORD" -e \
            "CREATE DATABASE \`$NEW_DB_NAME\`;"
            
        docker exec -i "$DB_HOST" mysql -u"root" -p"$DB_ROOT_PASSWORD" -e \
            "CREATE USER '$NEW_USER_NAME'@'%' IDENTIFIED BY '$NEW_USER_PASSWORD';"
    }
}

describe "Database Security Tests"

context "SQL Injection Prevention"
    it "should reject database names with SQL injection attempts"
        # Test various SQL injection patterns
        approve "create_new_database_and_user \"test'; DROP DATABASE mysql; --\" \"testuser\" \"testpass\""
        expect_exit_code 1
        
    it "should reject usernames with SQL injection attempts"  
        approve "create_new_database_and_user \"testdb\" \"test'; DROP USER root; --\" \"testpass\""
        expect_exit_code 1
        
    it "should reject passwords with SQL injection attempts"
        approve "create_new_database_and_user \"testdb\" \"testuser\" \"pass'; DROP TABLE users; --\""
        expect_exit_code 1

context "Special Character Handling"
    it "should handle passwords with hash symbols"
        approve "create_new_database_and_user \"testdb\" \"testuser\" \"mypass#123\""
        expect_exit_code 0
        
    it "should handle passwords with quotes"
        approve "create_new_database_and_user \"testdb\" \"testuser\" \"my'pass\""
        expect_exit_code 0
        
    it "should handle passwords with backticks"
        approve "create_new_database_and_user \"testdb\" \"testuser\" \"my\`pass\""
        expect_exit_code 0

context "Input Validation"
    it "should reject empty database names"
        approve "create_new_database_and_user \"\" \"testuser\" \"testpass\""
        expect_exit_code 1
        
    it "should reject empty usernames"
        approve "create_new_database_and_user \"testdb\" \"\" \"testpass\""
        expect_exit_code 1
        
    it "should reject empty passwords"
        approve "create_new_database_and_user \"testdb\" \"testuser\" \"\""
        expect_exit_code 1

context "Valid Inputs"
    it "should accept normal database creation"
        approve "create_new_database_and_user \"my_app_db\" \"my_app_user\" \"secure_password_123\""
        expect_exit_code 0
        
    it "should accept database names with underscores"
        approve "create_new_database_and_user \"test_app_production\" \"test_user\" \"password123\""
        expect_exit_code 0
