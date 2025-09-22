#!/usr/bin/env bash
# Simple integration tests for CLI

cd "$(dirname "$0")/.."
source approvals.bash

describe "CLI Integration Tests"

context "Script Existence and Basic Functionality"
    it "should check if ez script exists"
        if [[ -f "../ez" ]]; then
            approve "echo 'ez script found'"
        else
            approve "echo 'ez script not found - this is expected in current setup'"
        fi
        
    it "should test script permissions"
        if [[ -f "../ez" ]]; then
            if [[ -x "../ez" ]]; then
                approve "echo 'ez script is executable'"
            else
                approve "echo 'ez script exists but is not executable'"
            fi
        else
            approve "echo 'ez script not found - permissions test skipped'"
        fi

context "Basic Directory Structure"
    it "should verify src directory structure"
        approve "ls -la ../src/ | head -5"
        
    it "should verify lib directory structure"
        approve "ls -la ../src/lib/ | head -5"

context "Configuration Files"
    it "should check for bashly configuration"
        if [[ -f "../src/bashly.yml" ]]; then
            approve "echo 'bashly.yml found' && head -5 ../src/bashly.yml"
        else
            approve "echo 'bashly.yml not found'"
        fi