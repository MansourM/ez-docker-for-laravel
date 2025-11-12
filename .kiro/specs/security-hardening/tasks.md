# Security Hardening Implementation Plan

## Phase 1: Critical Security Fixes

- [x] 1. Create security configuration management






- [x] 1.1 Create `.env.example` in root directory

  - Add pinned Docker image versions (NGINX_PM_VERSION=2.11.1, MYSQL_VERSION=8.0.35, etc.)
  - Add security settings (DB_NETWORK_RESTRICTION=172.%.%.%, password length limits)
  - Add comments explaining each configuration option


  - _Requirements: 2.1, 2.2_

- [x] 1.2 Update `.gitignore` to exclude `.env` file


  - Add `.env` to gitignore (keep `.env.example` tracked)
  - Ensure local configurations remain private
  - _Requirements: 2.1_

- [x] 1.3 Update `docker/common-shared.yml` to use environment variables




  - Replace `jc21/nginx-proxy-manager:latest` with `${NGINX_PM_VERSION:-2.11.1}`
  - Replace `mysql:8.0` with `mysql:${MYSQL_VERSION:-8.0.35}`


  - Replace `phpmyadmin` with `phpmyadmin:${PHPMYADMIN_VERSION:-5.2.1}`
  - Replace `portainer/portainer-ce:latest` with `${PORTAINER_VERSION:-2.19.4}`
  - Test that containers start correctly with pinned versions
  - _Requirements: 2.1, 2.2_


- [x] 2. Fix database password injection vulnerability


- [-] 2.1 Create security library directory structure

  - Create `src/lib/security/` directory
  - _Requirements: 1.1, 1.3_


- [-] 2.2 Create database security module



  - Create `src/lib/security/db_security.sh` with secure wrapper functions
  - Implement `execute_mysql_command()` using here-doc to avoid bash interpolation
  - Implement `create_database_secure()` with identifier validation
  - Implement `create_user_secure()` with network restriction parameter
  - Add proper MySQL identifier quoting (backticks for database/table names)


  - _Requirements: 1.1, 1.3, 1.4_

- [ ] 2.3 Update database creation script to use secure functions
  - Modify `src/lib/create_new_database_and_user.sh` to source `db_security.sh`
  - Replace direct MySQL commands with secure wrapper functions

  - Update to use network-restricted user creation (172.%.%.%)
  - Test with passwords containing special characters (#, $, !, etc.)
  - Verify database operations work correctly with new implementation
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 3. Add strict error handling to all scripts




- [x] 3.1 Add `set -euo pipefail` to command scripts

  - Update `src/laravel_deploy_command.sh` to include strict error handling








  - Update `src/laravel_new_command.sh` to include strict error handling
  - Update `src/shared_deploy_command.sh` to include strict error handling
  - Update all other command scripts in `src/` directory


  - _Requirements: 4.1_



- [x] 3.2 Add `set -euo pipefail` to library functions

  - Update all scripts in `src/lib/` directory

  - Ensure error handling doesn't break existing functionality
  - Test that errors are properly propagated





  - _Requirements: 4.1_

## Phase 2: Input Validation and Error Handling

- [x] 4. Create input validation framework

- [x] 4.1 Create input validator module
  - Create `src/lib/security/input_validator.sh`
  - Implement `validate_app_name()` - alphanumeric, hyphens, underscores, max 64 chars
  - Implement `validate_environment()` - restrict to dev|test|staging|production
  - Implement `validate_git_url()` - validate Git URL format
  - Implement `sanitize_password()` - use printf %q for bash-safe quoting
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [x] 4.2 Integrate validation into laravel new command
  - Source `input_validator.sh` in `src/laravel_new_command.sh`
  - Add validation for app name before creating directories
  - Add validation for Git URL before cloning
  - Add clear error messages with examples when validation fails
  - _Requirements: 6.1, 6.3_

- [x] 4.3 Integrate validation into laravel deploy command
  - Source `input_validator.sh` in `src/laravel_deploy_command.sh`
  - Add validation for app name and environment
  - Add validation for database credentials
  - Improve error messages to be actionable
  - _Requirements: 6.1, 6.2, 6.4_

- [x] 5. Improve error handling and messaging
- [x] 5.1 Standardize error messages in deployment script



  - Update `src/laravel_deploy_command.sh` error messages
  - Change line 44 warning to error for missing APP_PORT in test environment
  - Add context and suggestions to all error messages
  - Ensure errors don't expose sensitive information
  - _Requirements: 4.2, 4.4, 4.5_

- [x] 5.2 Add error handling for Docker operations
  - Add checks for Docker daemon availability
  - Add checks for container health before operations
  - Provide clear error messages for Docker failures
  - _Requirements: 4.2, 4.4_

- [x] 6. Consolidate duplicate merge_env functions


  - Review `src/lib/merge_envs.sh` (newer implementation)
  - Review `test/test.sh` (older implementation)
  - Remove duplicate from `test/test.sh`
  - Update test files to source and use `src/lib/merge_envs.sh`
  - _Requirements: 4.1_

## Phase 3: Configuration Security






- [x] 7. Add comprehensive security headers
- [x] 7.1 Create security headers configuration file
  - Create `template/security/` directory
  - Create `template/security/nginx-security.conf`
  - Add HSTS header (Strict-Transport-Security with max-age=31536000)
  - Add CSP header (Content-Security-Policy with appropriate directives)


  - Add X-XSS-Protection, Referrer-Policy, Permissions-Policy headers
  - Add server_tokens off to hide Nginx version
  - _Requirements: 5.1_

- [x] 7.2 Integrate security headers into Nginx configuration
  - Update `template/nginx/default.conf` to include security-headers.conf
  - Keep existing X-Frame-Options and X-Content-Type-Options headers
  - Update `template/laravel.Dockerfile` to copy security-headers.conf
  - Test that security headers are properly applied in responses
  - _Requirements: 5.1_

- [x] 8. Fix PHP error logging





- [x] 8.1 Create PHP log directory in Dockerfile
  - Update `template/laravel.Dockerfile` to create `/var/log/php` directory
  - Set proper ownership and permissions for log directory
  - Ensure directory is created before PHP-FPM starts


  - _Requirements: 4.2_

- [x] 8.2 Update PHP configuration for proper logging
  - Verify `template/php.ini` has correct error_log path
  - Ensure log_errors=On and display_errors=Off for production
  - Add environment-specific display_errors configuration
  - Test that PHP errors are properly logged
  - _Requirements: 4.2, 4.3_

- [x] 9. Implement environment-specific OPcache configuration



- [x] 9.1 Create environment-aware OPcache configuration


  - Update `template/opcache.ini` to use OPCACHE_VALIDATE_TIMESTAMPS variable
  - Set default to 1 (development-friendly)
  - Document that production should set to 0
  - _Requirements: 5.2, 5.3_


- [x] 9.2 Add OPcache environment variables to env files

  - Add OPCACHE_VALIDATE_TIMESTAMPS=1 to dev.env template
  - Add OPCACHE_VALIDATE_TIMESTAMPS=0 to production.env template
  - Update docker-compose to pass environment variable to container
  - Test that dev allows code updates, production optimizes performance
  - _Requirements: 5.2, 5.3_

- [x] 10. Clean up Nginx configuration



  - Review `template/nginx/default.conf` for unused configurations
  - Remove or document WebSocket configuration at line 68-77
  - Ensure all configurations are necessary and documented
  - _Requirements: 5.1_



## Phase 4: Testing and Monitoring

- [ ] 11. Create input validation tests
- [ ] 11.1 Create test file for input validation
  - Create `test/security/test_input_validation.sh`
  - Source the Approvals.bash framework
  - Source `src/lib/security/input_validator.sh`
  - _Requirements: 10.1, 10.3_

- [ ] 11.2 Write validation test cases
  - Test valid app names (alphanumeric, hyphens, underscores)
  - Test invalid app names (special characters, too long)
  - Test valid environments (dev, test, staging, production)
  - Test invalid environments (prod, development, etc.)
  - Test valid Git URLs (https, git, ssh formats)
  - Test invalid Git URLs (malformed, missing .git)
  - Test password sanitization with special characters
  - _Requirements: 10.1, 10.3_

- [ ] 12. Create database security tests
- [ ] 12.1 Enhance existing database security tests
  - Update `test/security/test_database_security.sh`
  - Add test for network restriction (verify 172.%.%.% host pattern)
  - Add test for special character password handling
  - Add test for database name validation
  - Add test for username validation
  - _Requirements: 10.1, 10.3_

- [ ] 12.2 Enhance SQL injection tests
  - Update `test/security/test_sql_injection.sh`
  - Test SQL injection in database name
  - Test SQL injection in username
  - Test SQL injection in password
  - Verify all attempts are blocked by validation
  - _Requirements: 10.1, 10.3_

- [ ] 13. Create integration tests for security fixes
- [ ] 13.1 Create secure deployment integration test
  - Create `test/integration/test_secure_deployment.sh`
  - Test full deployment workflow with validated inputs
  - Test database creation with network restrictions
  - Verify Docker image version pinning works
  - Test error handling for invalid inputs
  - _Requirements: 10.2_

- [ ] 13.2 Add test cleanup and verification
  - Ensure tests clean up created resources
  - Verify security configurations are applied
  - Test rollback scenarios
  - _Requirements: 10.2_

- [ ] 14. Enhance health check monitoring
  - Review existing health checks in `docker/common-shared.yml`
  - Document health check configuration
  - Add health check documentation to README
  - Test that health checks properly detect service failures
  - _Requirements: 9.1, 9.2_

## Phase 5: Documentation and Privilege Management

- [ ] 15. Remove sudo requirements
- [ ] 15.1 Update before.sh to check Docker access instead of root
  - Remove EUID check from `src/before.sh`
  - Add Docker daemon connectivity check
  - Provide helpful error message about Docker group membership
  - Include instructions for adding user to docker group
  - _Requirements: 3.1, 3.2_

- [ ] 15.2 Update documentation for Docker group setup
  - Update README.md with Docker group setup instructions
  - Document how to add user to docker group
  - Explain newgrp command for immediate activation
  - Update all command examples to remove sudo
  - _Requirements: 3.1, 3.2, 11.1_

- [ ] 16. Improve documentation
- [ ] 16.1 Update README with security features
  - Add Security Features section describing all improvements
  - Document input validation requirements
  - Document network restrictions for database access
  - Document Docker image version pinning
  - Document security headers
  - _Requirements: 11.1, 11.2, 11.3_

- [ ] 16.2 Add platform requirements documentation
  - Clearly state Debian/Ubuntu Linux requirement
  - Document tested Ubuntu version (22.04.3 LTS)
  - Explain why other platforms are not supported
  - Document WSL2 requirements if Windows users want to try
  - _Requirements: 12.1, 12.2, 12.3, 12.4_

- [ ] 16.3 Create troubleshooting guide
  - Add Troubleshooting section to README
  - Document common Docker permission issues
  - Document database connection problems
  - Document special character password issues
  - Document container startup failures
  - Provide solutions for each common issue
  - _Requirements: 11.2, 11.3_

- [ ] 16.4 Create security documentation
  - Create `SECURITY.md` file
  - Document security features and threat model
  - Add vulnerability reporting process
  - Document security best practices for users
  - _Requirements: 11.1_

- [ ] 17. Create backup solution framework
  - Design automated backup strategy for databases and volumes
  - Create backup scripts using existing `mysqldump` capability
  - Implement backup scheduling and retention policies
  - Add restore procedures and validation scripts
  - Document backup/restore procedures
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

## Phase 6: Production Readiness

- [ ] 18. Final security audit and testing
- [ ] 18.1 Run complete test suite
  - Execute all unit tests in `test/unit/`
  - Execute all integration tests in `test/integration/`
  - Execute all security tests in `test/security/`
  - Verify all tests pass
  - _Requirements: 10.4_

- [ ] 18.2 Perform security audit
  - Review all implemented security changes
  - Verify SQL injection prevention works
  - Verify network restrictions are applied
  - Verify input validation catches malicious inputs
  - Verify security headers are present
  - Verify error handling doesn't expose sensitive info
  - _Requirements: 10.4_

- [ ] 18.3 Test full deployment workflow
  - Test in clean environment (fresh VM or container)
  - Test laravel new command with validation
  - Test laravel deploy command with security features
  - Test database creation with network restrictions
  - Test with passwords containing special characters
  - Verify all security configurations are applied
  - _Requirements: 10.4_

- [ ] 19. Update security review documentation
- [ ] 19.1 Update SECURITY_AND_IMPROVEMENTS_REVIEW.md
  - Mark all completed items with ✅ and completion date
  - Update overall security status to production ready
  - Update risk level from HIGH to LOW
  - Update production ready status from NO to YES
  - _Requirements: All requirements validation_

- [ ] 19.2 Document remaining known issues
  - List any residual risks (Docker daemon security, etc.)
  - Document any limitations or constraints
  - Provide recommendations for future improvements
  - _Requirements: All requirements validation_

- [ ] 19.3 Create final security assessment
  - Summarize all security improvements made
  - Document before/after security posture
  - List all vulnerabilities fixed
  - Provide production deployment checklist
  - _Requirements: All requirements validation_