---
inclusion: always
---

# Testing Workflow

## Environment Setup

This project is developed on **Windows with WSL (Windows Subsystem for Linux)** installed.

- **WSL Distribution**: Ubuntu 24.04
- **Project Path in WSL**: `/mnt/d/dev/workspace/docker/ez-docker-for-laravel`
- **Windows Path**: `D:\dev\workspace\docker\ez-docker-for-laravel`

## Running Tests

### Always Use WSL for Bash Scripts

Since this is a bash-based project (shell scripts, Docker, etc.), **all bash commands and tests MUST be run through WSL**.

**Run all tests (default: auto-approve, quiet):**
```powershell
wsl bash test/run_all_tests.sh
```

**Run with options:**
```powershell
# Interactive mode (prompt for approvals)
wsl bash test/run_all_tests.sh -i

# Verbose mode (show full command details)
wsl bash test/run_all_tests.sh -v

# Both interactive and verbose
wsl bash test/run_all_tests.sh -i -v

# Show help
wsl bash test/run_all_tests.sh --help
```

**Run specific test suite:**
```powershell
wsl bash test/unit/_run_tests.sh
wsl bash test/security/_run_tests.sh -v
wsl bash test/integration/_run_tests.sh -i
```

### Test Directory Structure

```
test/
├── unit/                    # Unit tests for individual functions
├── integration/             # Integration tests for full workflows
├── security/                # Security-specific tests
├── approvals.bash          # Approval testing framework
└── run_simple_tests.sh     # Test runner script
```

### Running Different Test Suites

```powershell
# Run all tests
wsl bash test/run_simple_tests.sh

# Run specific test file
wsl bash test/unit/test_env_config.sh
wsl bash test/security/test_db_security_module.sh

# Run integration tests
wsl bash test/integration/test_basic_commands.sh
```

## Test-Driven Development (TDD) Workflow

When implementing tasks from the spec:

1. **Write the test first** - Create test file in appropriate directory
2. **Run the test** - It should fail (red)
3. **Implement the feature** - Write minimal code to pass the test
4. **Run the test again** - It should pass (green)
5. **Refactor if needed** - Improve code while keeping tests passing

### Example TDD Cycle

```powershell
# 1. Create test
# Edit: test/security/test_input_validation.sh

# 2. Run test (should fail)
wsl bash test/security/test_input_validation.sh

# 3. Implement feature
# Edit: src/lib/security/input_validator.sh

# 4. Run test again (should pass)
wsl bash test/security/test_input_validation.sh

# 5. Run all tests to ensure nothing broke
wsl bash test/run_simple_tests.sh
```

## Important Notes

- **Never use `cd` in PowerShell commands** - Use full paths or WSL's working directory
- **Line endings**: WSL expects LF (Unix), not CRLF (Windows) - Git should handle this automatically
- **File permissions**: Files created in Windows may need chmod in WSL: `wsl chmod +x script.sh`
- **Docker**: Docker Desktop must be running and WSL integration enabled

## Debugging Tests

If tests fail:

1. **Check syntax errors**: Look for CRLF line ending issues
2. **Check file permissions**: Ensure scripts are executable
3. **Check paths**: Verify paths are correct for WSL environment
4. **Run with verbose output**: Add `-x` flag: `wsl bash -x test/unit/test_file.sh`

## Common Issues

### "command not found" errors
- Ensure the script has proper shebang: `#!/usr/bin/env bash`
- Check if the script is executable: `wsl chmod +x script.sh`

### "syntax error near unexpected token" with `\r`
- File has Windows line endings (CRLF)
- Fix: `wsl dos2unix filename.sh` or configure Git to use LF

### Docker not accessible
- Ensure Docker Desktop is running
- Check WSL integration is enabled in Docker Desktop settings
- Verify: `wsl docker ps`
