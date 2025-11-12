---
inclusion: always
---

# Approvals.bash Testing Framework

## Overview

This project uses **approvals.bash** for interactive approval testing of bash scripts.

## Key Concepts

**Approval Testing**: Compare command output with expected output stored in `approvals/` directory.
- New output → prompt to approve and save
- Changed output → show diff, prompt to approve
- Matching output → test passes
- Rejected approval → test fails immediately

## Basic Usage

```bash
#!/usr/bin/env bash
source approvals.bash

describe "Feature Name"
  context "specific scenario"
    it "should do something"
      approve "command to test"
      expect_exit_code 0
```

## Test Structure Commands

- `describe "text"` - Main feature description
- `context "text"` - Specific scenario context  
- `it "text"` - Individual test description
- `approve "command"` - Test command output
- `expect_exit_code N` - Verify exit code of last approved command
- `allow_diff "regex"` - Allow specific differences (e.g., timestamps)
- `fail "message"` - Trigger custom failure

## Configuration

- **Approvals directory**: `./approvals` (relative to test file)
- **Change directory**: Set `APPROVALS_DIR` before sourcing approvals.bash
- **Auto-approve all**: Set `AUTO_APPROVE=1` to skip prompts
- **CI mode**: Automatically non-interactive when `CI` or `GITHUB_ACTIONS` env vars exist

## Installation

Download to test folder:
```bash
wget get.dannyb.co/approvals.bash
```

Or from GitHub:
```bash
wget https://raw.githubusercontent.com/DannyBen/approvals.bash/master/approvals.bash
```

## Running Tests

```bash
# Run single test
bash test/unit/test_file.sh

# Run test suite
bash test/run_security_tests.sh
```

## Important Notes

- **Line endings**: Must be LF (Unix), not CRLF (Windows)
- **Bash version**: Requires bash 4.0+ or zsh
- **Unicode output**: May display incorrectly in PowerShell but tests still work
- **Exit codes**: Tests exit with code 1 on failure, 0 on success

## Project-Specific

- Suppress stderr in test runner to hide PowerShell encoding issues: `2>/dev/null`
- Mock functions (like `log()`) when testing library files that depend on them
- Use `export -f function_name` to make mocked functions available to subshells
