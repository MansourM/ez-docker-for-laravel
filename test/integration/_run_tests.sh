#!/usr/bin/env bash
# Run all integration tests

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interactive)
            export AUTO_APPROVE=0
            shift
            ;;
        -v|--verbose)
            export VERBOSE=1
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Auto-approve by default (set AUTO_APPROVE=0 to run interactively)
export AUTO_APPROVE=${AUTO_APPROVE:-1}

# Quiet mode for cleaner output (set VERBOSE=1 to see full details)
VERBOSE=${VERBOSE:-0}

# Change to the directory where this script is located
cd "$(dirname "$0")" || exit 1

echo "Running Integration Tests..."
echo "============================="

FAILED=0
PASSED=0
TOTAL=0

for test_file in test_*.sh; do
    if [[ -f "$test_file" ]]; then
        ((TOTAL++))
        echo "Running: $test_file"
        if [[ $VERBOSE -eq 1 ]]; then
            bash "$test_file"
            result=$?
        else
            # Strip ANSI colors, replace verbose approved lines, show only structure
            bash "$test_file" 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | sed -E 's/^  approved   .*/  ✓ passed/' | grep -E "^▌|^  ✓"
            result=${PIPESTATUS[0]}
        fi
        
        if [[ $result -eq 0 ]]; then
            echo "✓ PASSED"
            ((PASSED++))
        else
            echo "✗ FAILED"
            ((FAILED++))
        fi
        echo ""
    fi
done

echo "--------------------"
if [ $FAILED -eq 0 ]; then
    echo "✓ All $TOTAL integration test(s) passed!"
    exit 0
else
    echo "✗ $FAILED of $TOTAL integration test(s) failed ($PASSED passed)"
    exit 1
fi
