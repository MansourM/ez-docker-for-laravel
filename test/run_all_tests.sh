#!/usr/bin/env bash
# Master test runner - dynamically discovers and runs all test suites

# Parse command line arguments
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Run all test suites with configurable options.

OPTIONS:
    -i, --interactive    Run tests in interactive mode (prompt for approvals)
    -v, --verbose        Show full test output including commands
    -h, --help          Show this help message

EXAMPLES:
    $(basename "$0")                    # Run all tests (auto-approve, quiet)
    $(basename "$0") -i                 # Run interactively
    $(basename "$0") -v                 # Run with verbose output
    $(basename "$0") -i -v              # Interactive and verbose

ENVIRONMENT VARIABLES:
    AUTO_APPROVE=0      Same as --interactive
    VERBOSE=1           Same as --verbose
EOF
    exit 0
}

# Default values
export AUTO_APPROVE=${AUTO_APPROVE:-1}
export VERBOSE=${VERBOSE:-0}

# Parse arguments
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
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

echo "========================================"
echo "EZ Docker Test Suite - All Tests"
echo "========================================"
[[ $AUTO_APPROVE -eq 0 ]] && echo "Mode: Interactive"
[[ $VERBOSE -eq 1 ]] && echo "Output: Verbose"
echo ""

TOTAL_FAIL=0
TOTAL_PASS=0
TOTAL_SUITES=0
TEST_DIR="$(cd "$(dirname "$0")" && pwd)"

# Dynamically discover and run test suites
# Looks for _run_tests.sh in each subdirectory
for suite_dir in "$TEST_DIR"/*/; do
    # Skip if not a directory
    [[ ! -d "$suite_dir" ]] && continue
    
    suite_name=$(basename "$suite_dir")
    runner="$suite_dir/_run_tests.sh"
    
    # Skip special directories
    [[ "$suite_name" == "approvals" ]] && continue
    [[ "$suite_name" == "fixtures" ]] && continue
    [[ "$suite_name" == "tmp" ]] && continue
    
    # Check if _run_tests.sh exists
    if [[ -f "$runner" ]]; then
        ((TOTAL_SUITES++))
        # Pass flags to individual test runners
        flags=""
        [[ $AUTO_APPROVE -eq 0 ]] && flags="$flags --interactive"
        [[ $VERBOSE -eq 1 ]] && flags="$flags --verbose"
        
        if bash "$runner" $flags; then
            echo "✓ $suite_name tests passed"
            ((TOTAL_PASS++))
        else
            echo "✗ $suite_name tests failed"
            ((TOTAL_FAIL++))
        fi
        echo ""
    fi
done

echo "========================================"
echo "Final Results"
echo "========================================"

if [ $TOTAL_FAIL -eq 0 ]; then
    echo "✓ SUCCESS: All $TOTAL_SUITES test suite(s) passed!"
    exit 0
else
    echo "✗ FAILURE: $TOTAL_FAIL of $TOTAL_SUITES test suite(s) failed ($TOTAL_PASS passed)"
    exit 1
fi
