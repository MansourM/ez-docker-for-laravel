# Security Hardening Implementation Plan

## Phase 1: Critical Security Fixes

- [ ] 0. Improve project folder structure and naming
  - Review overlap between `docker/` and `template/` directories
  - Consider renaming or reorganizing for better clarity (e.g., `shared/` vs `templates/`)
  - Update documentation to reflect any structural changes
  - Ensure changes don't break existing functionality
  - _Requirements: Project organization improvement_

- [ ] 1. Create security configuration management
  - Create `.env.example` in root directory with pinned Docker image versions and security settings
  - Create `.env` file (gitignored) for local configuration
  - Update `docker/common-shared.yml` to use environment variables for image versions
  - Test that existing `load_env()` function properly loads the new configuration
  - _Requirements: 2.1, 2.2_

- [ ] 2. Fix database password injection vulnerability in bash context
  - Create secure wrapper functions in `src/lib/security/db_security.sh`
  - Implement proper bash variable escaping and validation for MySQL operations
  - Add input sanitization functions that work with bash string operations
  - Update `src/lib/create_new_database_and_user.sh` to use secure functions
  - Test with passwords containing special characters like # in bash context
  - _Requirements: 1.1, 1.3, 1.4_

- [ ] 3. Restrict MySQL network access in Docker environment
  - Update database user creation to use Docker network restriction (172.%.%.%)
  - Modify `create_new_database_and_user.sh` to use network-restricted grants
  - Test that database access works within Docker network but fails from outside
  - Ensure this works with the existing Docker Compose network setup
  - _Requirements: 1.2_

- [ ] 4. Pin Docker image versions using environment variables
  - Update `docker/common-shared.yml` to use specific versions from `.env`
  - Replace `latest` tags with environment variables (e.g., `${NGINX_PM_VERSION}`)
  - Add pinned versions to `.env.example` with current stable versions
  - Document version update process in comments
  - Test that containers start correctly with pinned versions
  - _Requirements: 2.1, 2.2_

## Phase 2: Input Validation and Error Handling

- [ ] 5. Create input validation framework
  - Create `src/lib/security/input_validator.sh` with validation functions
  - Implement `validate_app_name()`, `validate_environment()`, `validate_git_url()`
  - Add `sanitize_password()` function to handle special characters like #
  - Load security settings from `.env` in validation functions
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 6. Standardize error handling in command files
  - Add proper error handling to `src/laravel_deploy_command.sh`
  - Update `src/laravel_new_command.sh` to use validation functions
  - Ensure all command files handle errors consistently
  - Update error messages to be more descriptive and actionable
  - _Requirements: 4.2, 4.4_



- [ ] 7. Consolidate duplicate merge_env functions
  - Review `src/lib/merge_envs.sh` and `test/test.sh` implementations
  - Keep the better implementation and remove duplicates
  - Update any references to use the consolidated function
  - Add tests for the merge_env functionality
  - _Requirements: 4.1_

## Phase 3: Configuration Security

- [ ] 8. Add comprehensive security headers
  - Create `template/security/nginx-security.conf` with all security headers
  - Include HSTS, CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy
  - Update `template/nginx/default.conf` to include security configuration
  - Test security headers are properly applied
  - _Requirements: 5.1_

- [ ] 9. Implement environment-specific OPcache configuration
  - Create `template/security/opcache-env.ini` with environment variables
  - Set `opcache.validate_timestamps=1` for dev, `=0` for production
  - Update Dockerfiles to use environment-specific OPcache settings
  - Test that development allows code updates, production optimizes performance
  - _Requirements: 5.2, 5.3_



## Phase 4: Testing and Monitoring

- [ ] 10. Expand security testing framework
  - Create `test/security/test_input_validation.sh` using Approvals.bash
  - Add `test/security/test_database_security.sh` for SQL injection prevention
  - Create `test/security/test_network_security.sh` for access control testing
  - Implement tests for password handling with special characters
  - _Requirements: 10.1, 10.3_

- [ ] 11. Add integration tests for security fixes
  - Create `test/integration/test_secure_deployment.sh` for full workflow testing
  - Test database creation with network restrictions
  - Verify Docker image version pinning works correctly
  - Test input validation in real deployment scenarios
  - _Requirements: 10.2_

- [ ] 12. Enhance health check monitoring
  - Review existing health checks in `docker/common-shared.yml`
  - Add health check endpoints for Laravel applications
  - Implement basic monitoring for container health status
  - Test that health checks properly detect service failures
  - _Requirements: 9.1, 9.2_

## Phase 5: Documentation and Backup



- [ ] 13. Create backup solution framework
  - Design automated backup strategy for databases and volumes
  - Create backup scripts using existing `mysqldump` capability
  - Implement backup scheduling and retention policies
  - Add restore procedures and validation scripts
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [ ] 14. Improve documentation and user experience
  - Update README.md with security improvements and requirements
  - Document platform requirements (Debian/Ubuntu Linux)
  - Add troubleshooting guide for common security-related issues
  - Create examples of secure deployment workflows
  - _Requirements: 11.1, 11.2, 11.3, 12.1_

## Phase 6: Production Readiness

- [ ] 15. Remove sudo requirements
  - Document Docker group setup for users
  - Update installation instructions to include Docker group configuration
  - Test that all commands work without sudo when user is in docker group
  - Update documentation to reflect privilege changes
  - _Requirements: 3.1, 3.2_

- [ ] 16. Final security audit and testing
  - Run complete test suite with all security improvements
  - Perform security audit of all implemented changes
  - Test full deployment workflow in clean environment
  - Validate that all critical security issues are resolved
  - _Requirements: 10.4_

- [ ] 17. Update security review status
  - Mark completed items in `SECURITY_AND_IMPROVEMENTS_REVIEW.md`
  - Update overall security status and production readiness
  - Document any remaining known issues or limitations
  - Create final security assessment report
  - _Requirements: All requirements validation_