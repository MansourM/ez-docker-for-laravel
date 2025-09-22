#!/usr/bin/env bash
# Basic integration tests for ez command line interface

# Set up paths
TEST_DIR="$(dirname "$0")"
PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"

source "$(dirname "$0")/../approvals.bash"

describe "Ez CLI Integration Tests"

context "Help Commands"
    it "should show main help"
        # Test the main ez help command
        # Note: These will need to be run in WSL where the ez script works
        approve "$PROJECT_ROOT/ez --help"
        
    it "should show docker help"
        approve "$PROJECT_ROOT/ez docker --help"
        
    it "should show laravel help"
        approve "$PROJECT_ROOT/ez laravel --help"
        
    it "should show shared help"
        approve "$PROJECT_ROOT/ez shared --help"

context "Version Information"
    it "should show version"
        approve "$PROJECT_ROOT/ez --version"

context "Command Validation"
    it "should reject invalid commands"
        approve "$PROJECT_ROOT/ez invalid_command"
        expect_exit_code 1
        
    it "should require arguments for laravel deploy"
        approve "$PROJECT_ROOT/ez laravel deploy"
        expect_exit_code 1
