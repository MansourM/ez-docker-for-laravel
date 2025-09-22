#!/usr/bin/env bash
# Basic unit tests following approval testing best practices

cd "$(dirname "$0")/.."
source approvals.bash

describe "Basic Library Functions"

context "Simple Tests Without Dependencies"
    it "should run basic echo command"
        approve "echo 'Hello from test'"

    it "should test basic file operations"
        approve "mkdir -p tmp && echo 'test content' > tmp/test.txt && cat tmp/test.txt && rm -f tmp/test.txt"

context "Log Function Tests"
    it "should source log function"
        approve "source ../src/lib/log.sh 2>&1 && echo 'log.sh sourced successfully'"

    it "should call log function with message"
        source ../src/lib/log.sh
        approve "log 'test message'"

    it "should handle log function with wrong arguments"
        source ../src/lib/log.sh
        approve "log 'arg1' 'arg2' 2>&1 || echo 'Exit code: $?'"
        
context "Other Logging Functions"
    it "should test log_info"
        source ../src/lib/log_info.sh
        approve "log_info 'info message'"
        
    it "should test log_error"
        source ../src/lib/log_error.sh
        approve "log_error 'error message'"
        
    it "should test log_success"
        source ../src/lib/log_success.sh
        approve "log_success 'success message'"