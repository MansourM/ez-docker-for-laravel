# Security Policy

## Overview

EZ Docker For Laravel takes security seriously. This document outlines our security features, threat model, vulnerability reporting process, and best practices for users.

## Security Features

### 1. Input Validation & Injection Prevention

**SQL Injection Protection:**
- All database identifiers (names, usernames) validated against strict patterns
- Only alphanumeric characters and underscores allowed
- MySQL identifier quoting with backticks
- Password sanitization for special character handling
- No direct string interpolation in SQL commands

**Command Injection Protection:**
- Input validation for all user-provided values
- Strict patterns for app names, environments, Git URLs
- No shell command execution with unvalidated input
- Proper quoting and escaping throughout

**Validation Rules:**
- **App names**: `^[a-zA-Z0-9_-]+$` (max 64 chars)
- **Environments**: Whitelist only (`dev`, `test`, `staging`, `production`)
- **Database names**: `^[a-zA-Z0-9_]+$` (max 64 chars)
- **Usernames**: `^[a-zA-Z0-9_]+$` (max 32 chars)
- **Git URLs**: Valid URL format with protocol

### 2. Network Security

**Database Access:**
- MySQL application users are granted host `'%'` for broad compatibility across Docker networks
- Network isolation between containers is provided by Docker networks
- Database ports are not published to the host by default

**Service Exposure:**
- Development/test: Exposed on `APP_PORT` only
- Staging/production: Behind Nginx Proxy Manager
- No unnecessary port exposure
- Firewall-friendly configuration

### 3. Docker Security

**Image Version Pinning:**
- All critical services use pinned versions
- No `latest` tags in production
- Version management through `.env` configuration
- Controlled updates with testing

**Pinned Versions:**
- Nginx Proxy Manager: 2.11.1
- MySQL: 8.0.35
- phpMyAdmin: 5.2.1
- Portainer: 2.19.4

**Container Security:**
- Health checks for automatic recovery
- Restart policies for high availability
- Resource limits (configurable)
- Security options (no-new-privileges for Portainer)

### 4. Configuration Security

**Environment Variables:**
- Sensitive data in `.env` files (not in code)
- `.env` excluded from version control
- `.env.example` as template (no secrets)
- Environment-specific configurations

**Security Headers:**
- `Strict-Transport-Security`: HSTS with 1-year max-age
- `Content-Security-Policy`: Restrictive CSP
- `X-Frame-Options`: DENY (clickjacking protection)
- `X-Content-Type-Options`: nosniff
- `X-XSS-Protection`: 1; mode=block
- `Referrer-Policy`: strict-origin-when-cross-origin
- `Permissions-Policy`: Restrictive permissions
- `server_tokens off`: Hide Nginx version

**PHP Security:**
- `display_errors=Off` in production
- Error logging to files only
- OPcache optimization per environment
- Secure session configuration

### 5. Error Handling

**Secure Error Messages:**
- No sensitive information in error output
- No stack traces to users
- Detailed logging for debugging
- User-friendly error messages

### 6. Access Control

**Privilege Management:**
- No root requirement (Docker group membership)
- Minimal privilege principle
- Secure file permissions
- User-specific configurations

**Authentication:**
- Strong password generation (20+ characters)
- Special character support
- No default passwords
- Password complexity encouraged

## Threat Model

### In Scope

**Protected Against:**
- SQL injection attacks
- Command injection attacks
- Path traversal attacks
- Unauthorized database access
- Container escape attempts
- Version-specific vulnerabilities (through pinning)
- Clickjacking attacks
- XSS attacks (through headers)
- Information disclosure

### Out of Scope

**Not Protected Against:**
- Physical access to the host
- Compromised Docker daemon
- Kernel vulnerabilities
- Network-level attacks (DDoS, etc.)
- Social engineering
- Compromised dependencies (supply chain)

**User Responsibilities:**
- Keep host system updated
- Secure Docker daemon
- Manage firewall rules
- Secure SSH access
- Backup data regularly
- Monitor logs

## Security Best Practices

### For Deployment

1. **Use Strong Passwords:**
   - Use long, randomly generated passwords (20+ characters)
   - Do not reuse credentials across environments
   - Never rely on default passwords

2. **Keep Systems Updated:**
   ```bash
   # Update host system
   sudo apt update && sudo apt upgrade
   
   # Update Docker images (test first!)
   docker-compose pull
   ```

3. **Enable Firewall:**
   ```bash
   # Allow only necessary ports
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 22/tcp
   sudo ufw enable
   ```

4. **Regular Backups:**
   ```bash
   # Backup databases
   docker exec mysql8 mysqldump -u root -p{password} --all-databases > backup.sql
   
   # Backup volumes
   docker run --rm -v shared_mysql:/data -v $(pwd):/backup ubuntu tar czf /backup/mysql-backup.tar.gz /data
   ```

5. **Monitor Logs:**
   ```bash
   # Check container logs
   docker logs <container_name>
   
   # Monitor health status
   docker ps --format "table {{.Names}}\t{{.Status}}"
   ```

### For Development

1. **Never Commit Secrets:**
   - Use `.env` files (gitignored)
   - Use `.env.example` for templates
   - Review commits before pushing

2. **Validate Inputs:**
   - Always validate user input
   - Use provided validation functions
   - Test with malicious inputs

3. **Follow Secure Coding:**
   - Handle errors explicitly
   - Avoid eval and dynamic execution
   - Quote variables properly
   - Use functions from the input validation module

## Vulnerability Reporting

### Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

**DO:**
- Email: sm.mirbehbahani@gmail.com
- Include detailed description
- Provide steps to reproduce
- Suggest a fix if possible
- Allow time for fix before disclosure

**DON'T:**
- Open public GitHub issues for security bugs
- Disclose publicly before fix is available
- Exploit the vulnerability

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 1 week
- **Fix Development**: Depends on severity
  - Critical: Within 1 week
  - High: Within 2 weeks
  - Medium: Within 1 month
  - Low: Next release
- **Public Disclosure**: After fix is released

### Severity Levels

**Critical:**
- Remote code execution
- SQL injection with data access
- Authentication bypass
- Container escape

**High:**
- Privilege escalation
- Sensitive data exposure
- Denial of service

**Medium:**
- Information disclosure
- Missing security headers
- Weak cryptography

**Low:**
- Security misconfigurations
- Best practice violations

## Security Updates

### Staying Informed

- Watch the [GitHub repository](https://github.com/MansourM/ez-docker-for-laravel)
- Check [releases](https://github.com/MansourM/ez-docker-for-laravel/releases) for security updates

### Applying Updates

```bash
# Pull latest changes
git pull origin main

# Review changes
git log --oneline -10

# Regenerate CLI if needed
sudo bashly generate

# Test in non-production first
./ez --version
```

## Security Checklist

### Before Production Deployment

- [ ] Change all default passwords
- [ ] Review and update `.env` files
- [ ] Enable firewall with minimal ports
- [ ] Set up SSL/TLS certificates
- [ ] Configure Nginx Proxy Manager
- [ ] Test database connectivity
- [ ] Verify health checks working
- [ ] Set up monitoring and alerting
- [ ] Configure automated backups
- [ ] Review security headers
- [ ] Test with security scanner
- [ ] Document custom configurations
- [ ] Set up log rotation
- [ ] Review file permissions
- [ ] Disable debug mode
- [ ] Test disaster recovery

### Regular Maintenance

- [ ] Update host system monthly
- [ ] Review Docker image updates
- [ ] Check security advisories
- [ ] Rotate passwords quarterly
- [ ] Review access logs
- [ ] Test backup restoration
- [ ] Verify health check status
- [ ] Update SSL certificates
- [ ] Review firewall rules
- [ ] Audit user access

## Compliance

### Data Protection

- No personal data collected by the tool
- User responsible for application data
- Database encryption at rest (user-configured)
- TLS encryption in transit (via Nginx PM)

### Logging

- No sensitive data in logs
- Passwords never logged
- Error logs contain no secrets
- User responsible for log retention

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [Laravel Security](https://laravel.com/docs/security)

## Contact

For security concerns:
- **Email**: sm.mirbehbahani@gmail.com
- **GitHub**: [@MansourM](https://github.com/MansourM)

For general questions:
- **GitHub Issues**: [Create an issue](https://github.com/MansourM/ez-docker-for-laravel/issues)
- **GitHub Discussions**: [Start a discussion](https://github.com/MansourM/ez-docker-for-laravel/discussions)

---

**Last Updated**: November 2024  
**Version**: 1.0.0
