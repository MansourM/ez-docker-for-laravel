# Testing Framework for Ez-Docker-for-Laravel

This directory contains comprehensive tests for the ez-docker-for-laravel project using the Approvals.bash testing framework.

## Prerequisites

- **WSL/Linux Environment**: Tests must be run in a Linux environment (WSL on Windows)
- **Bash 4.0+**: Required for associative arrays and other features
- **Docker**: For integration tests
- **Git**: For version control operations

## Testing Framework

We use [Approvals.bash](https://github.com/DannyBen/approvals.bash) - an interactive approval testing framework that:
- Captures command output and prompts for approval
- Automatically detects changes in output
- Allows regex-based output filtering for dynamic content
- Supports CI/CD environments

## Test Structure

```
test/
├── README.md                    # This file
├── approvals.bash              # Testing framework
├── approve                     # Example test runner
├── unit/                       # Unit tests for individual functions
│   ├── test_lib_functions.sh   # Library function tests
│   ├── test_env_handling.sh    # Environment handling tests
│   └── test_validation.sh      # Input validation tests
├── integration/                # Integration tests
│   ├── test_docker_setup.sh    # Docker environment tests
│   ├── test_laravel_deploy.sh  # Full deployment tests
│   └── test_shared_services.sh # Shared services tests
├── security/                   # Security-focused tests
│   ├── test_input_validation.sh # SQL injection prevention
│   ├── test_permissions.sh     # File/container permissions
│   └── test_network_security.sh # Network isolation tests
└── approvals/                  # Approved test outputs (auto-generated)
```

## Running Tests

### All Tests
```bash
# From WSL/Linux terminal in project root
cd test
./run_simple_tests.sh
```

### Quick Setup Test
```bash
cd test
./quick_test.sh
```

### Specific Test Categories
```bash
# Unit tests only
./run_unit_tests.sh

# Integration tests only  
./run_integration_tests.sh

# Security tests only
./run_security_tests.sh
```

### Individual Test Files
```bash
# Run specific test file
./unit/test_lib_functions.sh
```

## Writing Tests

### Basic Test Structure
```bash
#!/usr/bin/env bash
# Always run from test directory and source approvals.bash
cd "$(dirname "$0")/.."
source approvals.bash

describe "Function Name"
  it "should do something specific"
    # Source the function you're testing
    source ../src/lib/function_file.sh
    
    # Test the function
    approve "function_to_test arg1 arg2"
    expect_exit_code 0
```

### Testing with Dynamic Content
```bash
# Filter out timestamps, IDs, etc.
allow_diff "\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}"
approve "command_that_outputs_timestamps"
```

### Testing Error Conditions
```bash
describe "Error Handling"
  it "should fail with invalid input"
    approve "command_with_invalid_input"
    expect_exit_code 1
```

## Test Guidelines

### Unit Tests
- Test individual functions in isolation
- Mock external dependencies where possible
- Focus on input validation and error handling
- Test both success and failure scenarios

### Integration Tests
- Test complete workflows
- Use real Docker containers when needed
- Test environment interactions
- Validate container health and connectivity

### Security Tests
- Test SQL injection prevention
- Validate input sanitization
- Check file permissions
- Test network isolation

## Continuous Integration

Tests are designed to work in CI environments:
- Use `AUTO_APPROVE=1` to automatically approve in CI
- All tests should be deterministic
- Use proper cleanup after each test

## Test Data Management

- Test fixtures in `test/fixtures/`
- Temporary files in `test/tmp/` (auto-cleaned)
- Mock data should be minimal and realistic
- No real credentials or sensitive data

## Troubleshooting

### Common Issues

**Permission Denied**
```bash
chmod +x test/*.sh
chmod +x test/*/*.sh
```

**WSL Docker Issues**
```bash
# Ensure Docker Desktop is running
# Verify WSL integration is enabled
docker version
```

**Approval File Conflicts**
```bash
# Reset all approvals (use carefully)
rm -rf test/approvals/
```

## Contributing

When adding new functionality:
1. Write tests first (TDD approach)
2. Ensure tests pass in clean environment  
3. Update this README if needed
4. Include both positive and negative test cases

## Test Coverage Goals

- [ ] **Unit Tests**: All library functions
- [ ] **Integration Tests**: All command workflows  
- [ ] **Security Tests**: All input vectors
- [ ] **Error Handling**: All failure modes
- [ ] **Documentation**: All examples work

---

*Tests should be run before every commit and all must pass before merging to main branch.*
