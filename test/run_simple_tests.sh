#!/usr/bin/env bash
# Simple test runner following approval testing best practices

set -euo pipefail

echo "🧪 Running Simple Tests (Approval Framework)"
echo "============================================="

cd "$(dirname "$0")"

echo "Current directory: $(pwd)"
echo ""

# Function to run a single test
run_test() {
    local test_file="$1"
    local test_name="$(basename "$test_file" .sh)"
    
    echo "🔍 Running $test_name..."
    
    if bash "$test_file"; then
        echo "✅ PASSED: $test_name"
        return 0
    else
        echo "❌ FAILED: $test_name"
        return 1
    fi
}

# Run tests
echo "📦 Unit Tests"
echo "-------------"
if [[ -f "unit/test_basic_functions.sh" ]]; then
    run_test "unit/test_basic_functions.sh"
else
    echo "⚠️  Unit test not found"
fi

echo ""
echo "🔒 Security Tests"
echo "----------------"
if [[ -f "security/test_sql_injection.sh" ]]; then
    run_test "security/test_sql_injection.sh"
else
    echo "⚠️  Security test not found"
fi

echo ""
echo "🔗 Integration Tests"
echo "-------------------"
if [[ -f "integration/test_cli_help.sh" ]]; then
    run_test "integration/test_cli_help.sh"
else
    echo "⚠️  Integration test not found"
fi

echo ""
echo "✅ Simple test run complete!"
echo ""
echo "📝 Note: These tests use the approval framework."
echo "   If prompted, press 'a' to approve new outputs."
