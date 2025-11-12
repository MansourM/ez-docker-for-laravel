#!/usr/bin/env bash
# Integration test for Docker health check configuration
# Verifies that all services have proper health checks configured

# Set approvals directory before sourcing approvals.bash
TEST_DIR="$(dirname "$0")"
export APPROVALS_DIR="$TEST_DIR/approvals"

source "$TEST_DIR/../approvals.bash"

PROJECT_ROOT="$(realpath "$TEST_DIR/../..")"
mkdir -p "$TEST_DIR/../tmp"

describe "Health Check Configuration Tests"

context "Health Check Presence"
    it "should have health checks configured for all critical services"
        approve "bash -c '
            COMPOSE_FILE=\"$PROJECT_ROOT/docker/common-shared.yml\"
            
            echo \"=== Services with Health Checks ===\"
            
            # Check Nginx Proxy Manager
            if grep -A 6 \"nginx-pm:\" \"\$COMPOSE_FILE\" | grep -q \"healthcheck:\"; then
                echo \"Nginx Proxy Manager: HAS_HEALTHCHECK\"
            else
                echo \"Nginx Proxy Manager: NO_HEALTHCHECK\"
            fi
            
            # Check MySQL
            if grep -A 10 \"mysql8:\" \"\$COMPOSE_FILE\" | grep -q \"healthcheck:\"; then
                echo \"MySQL: HAS_HEALTHCHECK\"
            else
                echo \"MySQL: NO_HEALTHCHECK\"
            fi
            
            # Check phpMyAdmin
            if grep -A 6 \"phpmyadmin:\" \"\$COMPOSE_FILE\" | grep -q \"healthcheck:\"; then
                echo \"phpMyAdmin: HAS_HEALTHCHECK\"
            else
                echo \"phpMyAdmin: NO_HEALTHCHECK\"
            fi
        ' 2>/dev/null" "services_with_healthchecks"

context "Health Check Parameters"
    it "should have proper interval configuration"
        approve "bash -c '
            COMPOSE_FILE=\"$PROJECT_ROOT/docker/common-shared.yml\"
            
            echo \"=== Health Check Intervals ===\"
            grep \"interval:\" \"\$COMPOSE_FILE\" | sed \"s/^[[:space:]]*//\" | sort | uniq -c
        ' 2>/dev/null" "healthcheck_intervals"
        
    it "should have proper timeout configuration"
        approve "bash -c '
            COMPOSE_FILE=\"$PROJECT_ROOT/docker/common-shared.yml\"
            
            echo \"=== Health Check Timeouts ===\"
            grep \"timeout:\" \"\$COMPOSE_FILE\" | sed \"s/^[[:space:]]*//\" | sort | uniq -c
        ' 2>/dev/null" "healthcheck_timeouts"
        
    it "should have proper retries configuration"
        approve "bash -c '
            COMPOSE_FILE=\"$PROJECT_ROOT/docker/common-shared.yml\"
            
            echo \"=== Health Check Retries ===\"
            grep \"retries:\" \"\$COMPOSE_FILE\" | sed \"s/^[[:space:]]*//\" | sort | uniq -c
        ' 2>/dev/null" "healthcheck_retries"
        
    it "should have proper start_period configuration"
        approve "bash -c '
            COMPOSE_FILE=\"$PROJECT_ROOT/docker/common-shared.yml\"
            
            echo \"=== Health Check Start Periods ===\"
            grep \"start_period:\" \"\$COMPOSE_FILE\" | sed \"s/^[[:space:]]*//\" | sort | uniq -c
        ' 2>/dev/null" "healthcheck_start_periods"

context "Health Check Commands"
    it "should use appropriate health check commands"
        approve "bash -c '
            COMPOSE_FILE=\"$PROJECT_ROOT/docker/common-shared.yml\"
            
            echo \"=== Health Check Test Commands ===\"
            
            # Extract health check test commands
            grep -A 1 \"test:\" \"\$COMPOSE_FILE\" | grep -E \"CMD|curl|mysqladmin\" | sed \"s/^[[:space:]]*-[[:space:]]*//\" | sed \"s/[\\\"\\[\\]]//g\" | sort
        ' 2>/dev/null" "healthcheck_commands"

context "Health Check Documentation"
    it "should have health check documentation in README"
        approve "bash -c '
            README=\"$PROJECT_ROOT/README.md\"
            
            if grep -q \"Health Check\" \"\$README\"; then
                echo \"README health check section: EXISTS\"
                
                # Count health check mentions
                grep -c \"health\" \"\$README\" | xargs echo \"Health mentions in README:\"
            else
                echo \"README health check section: MISSING\"
            fi
        ' 2>/dev/null" "readme_healthcheck_docs"
        
    it "should have dedicated health check documentation file"
        approve "bash -c '
            HEALTH_DOC=\"$PROJECT_ROOT/docs/HEALTH_CHECKS.md\"
            
            if [[ -f \"\$HEALTH_DOC\" ]]; then
                echo \"Health check documentation: EXISTS\"
                
                # Check for key sections
                grep -q \"## Overview\" \"\$HEALTH_DOC\" && echo \"Overview section: EXISTS\" || echo \"Overview section: MISSING\"
                grep -q \"## Health Check Configuration\" \"\$HEALTH_DOC\" && echo \"Configuration section: EXISTS\" || echo \"Configuration section: MISSING\"
                grep -q \"## Monitoring\" \"\$HEALTH_DOC\" && echo \"Monitoring section: EXISTS\" || echo \"Monitoring section: MISSING\"
                grep -q \"## Troubleshooting\" \"\$HEALTH_DOC\" && echo \"Troubleshooting section: EXISTS\" || echo \"Troubleshooting section: MISSING\"
            else
                echo \"Health check documentation: MISSING\"
            fi
        ' 2>/dev/null" "healthcheck_documentation"

context "Health Check Best Practices"
    it "should use reasonable health check intervals"
        approve "bash -c '
            COMPOSE_FILE=\"$PROJECT_ROOT/docker/common-shared.yml\"
            
            # Extract interval values (should be 30s or similar)
            intervals=\$(grep \"interval:\" \"\$COMPOSE_FILE\" | sed \"s/.*interval:[[:space:]]*//\" | sort | uniq)
            
            echo \"=== Interval Analysis ===\"
            for interval in \$intervals; do
                # Convert to seconds for comparison
                seconds=\${interval%s}
                
                if [[ \$seconds -ge 10 && \$seconds -le 60 ]]; then
                    echo \"Interval \$interval: REASONABLE (10-60s range)\"
                elif [[ \$seconds -lt 10 ]]; then
                    echo \"Interval \$interval: TOO_FREQUENT (< 10s)\"
                else
                    echo \"Interval \$interval: TOO_LONG (> 60s)\"
                fi
            done
        ' 2>/dev/null" "interval_analysis"
        
    it "should have adequate retry counts"
        approve "bash -c '
            COMPOSE_FILE=\"$PROJECT_ROOT/docker/common-shared.yml\"
            
            # Extract retry values
            retries=\$(grep \"retries:\" \"\$COMPOSE_FILE\" | sed \"s/.*retries:[[:space:]]*//\" | sort | uniq)
            
            echo \"=== Retry Analysis ===\"
            for retry in \$retries; do
                if [[ \$retry -ge 3 && \$retry -le 10 ]]; then
                    echo \"Retries \$retry: ADEQUATE (3-10 range)\"
                elif [[ \$retry -lt 3 ]]; then
                    echo \"Retries \$retry: TOO_FEW (< 3)\"
                else
                    echo \"Retries \$retry: TOO_MANY (> 10)\"
                fi
            done
        ' 2>/dev/null" "retry_analysis"
        
    it "should have sufficient start periods"
        approve "bash -c '
            COMPOSE_FILE=\"$PROJECT_ROOT/docker/common-shared.yml\"
            
            # Extract start_period values
            periods=\$(grep \"start_period:\" \"\$COMPOSE_FILE\" | sed \"s/.*start_period:[[:space:]]*//\" | sort | uniq)
            
            echo \"=== Start Period Analysis ===\"
            for period in \$periods; do
                seconds=\${period%s}
                
                if [[ \$seconds -ge 20 && \$seconds -le 60 ]]; then
                    echo \"Start period \$period: SUFFICIENT (20-60s range)\"
                elif [[ \$seconds -lt 20 ]]; then
                    echo \"Start period \$period: TOO_SHORT (< 20s)\"
                else
                    echo \"Start period \$period: VERY_LONG (> 60s)\"
                fi
            done
        ' 2>/dev/null" "start_period_analysis"

context "Restart Policy Integration"
    it "should have restart policies configured with health checks"
        approve "bash -c '
            COMPOSE_FILE=\"$PROJECT_ROOT/docker/common-shared.yml\"
            
            echo \"=== Restart Policies ===\"
            
            # Check restart policies for services with health checks
            services=(\"nginx-pm\" \"mysql8\" \"phpmyadmin\")
            
            for service in \"\${services[@]}\"; do
                restart_policy=\$(grep -A 15 \"\${service}:\" \"\$COMPOSE_FILE\" | grep \"restart:\" | sed \"s/.*restart:[[:space:]]*//\" | head -1)
                
                if [[ -n \"\$restart_policy\" ]]; then
                    echo \"\$service: \$restart_policy\"
                else
                    echo \"\$service: NO_RESTART_POLICY\"
                fi
            done
        ' 2>/dev/null" "restart_policies"

context "Health Check Command Validation"
    it "should use safe health check commands"
        approve "bash -c '
            COMPOSE_FILE=\"$PROJECT_ROOT/docker/common-shared.yml\"
            
            echo \"=== Health Check Command Safety ===\"
            
            # Check for potentially unsafe patterns
            if grep -A 1 \"test:\" \"\$COMPOSE_FILE\" | grep -q \"rm\\|delete\\|drop\"; then
                echo \"Destructive commands found: UNSAFE\"
            else
                echo \"No destructive commands: SAFE\"
            fi
            
            # Check for authentication in health checks
            if grep -A 1 \"test:\" \"\$COMPOSE_FILE\" | grep -q \"password\\|secret\\|key\"; then
                echo \"Credentials in health checks: SECURITY_RISK\"
            else
                echo \"No credentials in health checks: SECURE\"
            fi
            
            # Check for localhost usage (good practice)
            if grep -A 1 \"test:\" \"\$COMPOSE_FILE\" | grep -q \"localhost\"; then
                echo \"Uses localhost: GOOD_PRACTICE\"
            else
                echo \"No localhost usage: CHECK_NEEDED\"
            fi
        ' 2>/dev/null" "healthcheck_safety"

# Cleanup
rm -rf "$TEST_DIR/../tmp/"* 2>/dev/null || true
