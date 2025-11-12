# Testing Framework for Ez-Docker-for-Laravel

This directory contains tests for the ez-docker-for-laravel project using the **Approvals.bash** testing framework.

## Prerequisites

- **WSL/Linux Environment**: Tests must be run in WSL on Windows or native Linux
- **Bash 4.0+**: Required for approvals.bash framework
- **Docker**: For integration tests (future)

## Testing Framework

We use [Approvals.bash](https://github.com/DannyBen/approvals.bash) v0.5.1 - an interactive approval testing framework.

**How it works:**
- Captures command output and compares with approved files
- Shows diffs when output changes
- Prompts to approve/reject changes interactively
- Auto-approves in CI environments or with `AUTO_APPROVE=1`

## Current Test Structure

```
test/
├── README.md                           # This file
├── approvals.bash                      # Testing framework (v0.5.1)
├── run_security_tests.sh              # Main test runner
├── unit/                               # Unit tests
│   └── test_env_config.sh             # Environment configuration tests
├── security/                           # Security tests
│   └── test_db_security_module.sh     # Database security validation tests
├── integration/                        # Integration tests (future)
├── fixtures/                           # Test data files (future)
├── tmp/                                # Temporary test files (auto-cleaned)
└── approvals/                          # Approved test outputs (auto-generated)
```

## Running Tests

### Main Test Suite (All Tests)
```bash
# From project root (Windows PowerShell)
wsl bash test/run_security_tests.sh

# From WSL/Linux
cd test && bash run_security_tests.sh
```

### Test Suite by Category
```bash
# Unit tests only
wsl bash test/unit/run_tests.sh

# Security tests only
wsl bash test/security/run_tests.sh

# Integration tests only
wsl bash test/integration/run_tests.sh
```

### Individual Test Files
```bash
# Environment configuration tests
wsl bash test/unit/test_env_config.sh

# Database security tests
wsl bash test/security/test_db_security_module.sh
```

### Interactive Mode (Review Changes)
```bash
# Run without auto-approve to review changes
wsl bash -c "cd test && AUTO_APPROVE=0 bash run_security_tests.sh"
```

## Current Test Coverage

### ✅ Unit Tests
- **test_env_config.sh**: Environment configuration loading and validation
  - `.env.example` file existence and content
  - Docker Compose configuration with pinned versions
  - Environment variable loading
  - `.gitignore` configuration

### ✅ Security Tests  
- **test_db_security_module.sh**: Database security validation
  - Database name validation (SQL injection prevention)
  - Username validation (SQL injection prevention)
  - Password sanitization (special character handling)
  - Network restriction validation (Docker network only)
  - Security function existence checks

**Total: 15 test cases, all passing**

## Writing New Tests

### Basic Test Structure
```bash
#!/usr/bin/env bash
source "$(dirname "$0")/../approvals.bash"

# Setup
TEST_DIR="$(dirname "$0")"
PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"

describe "Feature Name"

context "Specific Scenario"
    it "should do something"
        approve "command to test" "custom_approval_name"
        expect_exit_code 0
```

### Key Points
- Use `approve "command"` to test command output
- Provide custom approval names for long commands
- Use `expect_exit_code N` to verify exit codes
- Suppress stderr with `2>/dev/null` if needed
- Use `bash -c '...'` for complex multi-line commands

### Example
```bash
it "should validate database names"
    approve "bash -c '
        source \"$PROJECT_ROOT/src/lib/security/db_security.sh\"
        validate_db_name \"test_db\" && echo \"VALID\" || echo \"INVALID\"
    ' 2>/dev/null" "db_name_validation"
```

## Test Guidelines

### Unit Tests (`test/unit/`)
- Test individual functions in isolation
- Mock dependencies when needed
- Focus on input/output validation
- Test both success and failure cases

### Security Tests (`test/security/`)
- Test SQL injection prevention
- Validate input sanitization
- Check access controls
- Test with malicious inputs

### Integration Tests (`test/integration/`)
- Test complete workflows (future)
- Use real Docker containers
- Test environment interactions
- Validate end-to-end scenarios

## Approval Files

Approval files are stored in `test/approvals/` and contain the expected output for each test.

**Managing Approvals:**
- First run: Creates approval file, prompts to approve
- Subsequent runs: Compares with approval file
- Changes detected: Shows diff, prompts to approve
- Auto-approve: Set `AUTO_APPROVE=1` to skip prompts

**Custom Approval Names:**
Use short custom names to avoid filename length issues:
```bash
approve "long command here" "short_name"
```

## Troubleshooting

### Tests Fail with "File name too long"
**Solution:** Add custom approval name as second parameter to `approve`

### Tests Prompt for Approval in CI
**Solution:** Set `AUTO_APPROVE=1` environment variable

### Unicode Characters Display Incorrectly
**Issue:** PowerShell encoding (cosmetic only, tests still work)
**Solution:** Tests work correctly despite display issues

### Permission Denied
```bash
wsl chmod +x test/*.sh
wsl chmod +x test/*/*.sh
```

## CI/CD Integration

Tests are designed for automated environments:
```bash
# In CI pipeline
export AUTO_APPROVE=1
bash test/run_security_tests.sh
```

## Future Test Coverage

- [ ] Integration tests for CLI commands
- [ ] Integration tests for Docker deployment
- [ ] Integration tests for Laravel setup
- [ ] Performance tests
- [ ] Load tests

## Contributing

When adding new functionality:
1. Write tests first (TDD)
2. Use `approve` command for output validation
3. Provide custom approval names for complex commands
4. Test both success and failure scenarios
5. Run full test suite before committing

---

**Current Status:** 15/15 tests passing ✅

*Last Updated: Security Hardening Phase 1 Complete*
