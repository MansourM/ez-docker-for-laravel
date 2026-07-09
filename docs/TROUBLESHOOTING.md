# Troubleshooting Guide

Complete troubleshooting guide for EZ Docker For Laravel. For quick reference, see the [README](../README.md#wrench-troubleshooting).

## Docker Permission Issues

### Problem
`Cannot connect to Docker daemon`

### Cause
Your user doesn't have permission to access Docker.

### Solution
```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Activate the group (or log out and back in)
newgrp docker

# Verify Docker access
docker ps
```

### Verification
If successful, `docker ps` should show running containers (or empty list) without errors.

---

## Database Connection Problems

### Problem
Laravel application can't connect to the database.

### Possible Causes
1. Incorrect database credentials
2. Database doesn't exist
3. MySQL container not running

### Solutions

#### 1. Check Database Credentials
```bash
# View current credentials
cat apps/{app_name}/env/{environment}.env | grep DB_

# Verify they match what's in MySQL
docker exec ez-docker-for-laravel-mysql8-1 mysql -uroot -p{DB_ROOT_PASSWORD} -e "SELECT user, host FROM mysql.user;"
```

#### 2. Verify Database Exists
```bash
docker exec ez-docker-for-laravel-mysql8-1 mysql -uroot -p{DB_ROOT_PASSWORD} -e "SHOW DATABASES;"
```

If database is missing, recreate it:
```bash
./ez laravel deploy {app_name} {environment}
```

#### 3. Check the User's Host Grant
Application database users are granted host `'%'` for broad compatibility. Verify the user exists:
```bash
docker exec ez-docker-for-laravel-mysql8-1 mysql -uroot -p{DB_ROOT_PASSWORD} -e "SELECT user, host FROM mysql.user WHERE user='{db_user}';"
```

The user's host should be `%`.

#### 4. Verify Container is Running
```bash
docker ps | grep mysql

# Check container health
docker ps --format "table {{.Names}}\t{{.Status}}" | grep mysql

# View container logs
docker logs ez-docker-for-laravel-mysql8-1 --tail 50
```

---

## Special Character Password Issues

### Problem
Passwords with special characters (#, $, !, etc.) not working.

### Cause
Special characters can be interpreted by the shell or MySQL if not properly handled.

### Solution
The system now properly handles special characters through password sanitization. If you still have issues:

#### 1. Avoid Problematic Characters
- Don't start passwords with `#` (interpreted as comment)
- Be careful with `$` (shell variable expansion)

#### 2. Verify Password in .env File
```bash
# Check the password is properly set
cat apps/{app_name}/env/{environment}.env | grep DB_PASSWORD

# Ensure it's not quoted (unless quotes are part of the password)
```

#### 3. Test Database Connection
```bash
# Test connection with the password
docker exec ez-docker-for-laravel-mysql8-1 mysql -u{db_user} -p'{db_password}' -e "SELECT 1;"
```

---

## Container Startup Failures

### Problem
Containers fail to start or become unhealthy.

### Diagnosis Steps

#### 1. Check Container Logs
```bash
# View recent logs
docker logs <container_name> --tail 100

# Follow logs in real-time
docker logs <container_name> --follow

# Check for errors
docker logs <container_name> 2>&1 | grep -i error
```

#### 2. Verify Health Status
```bash
# Check all containers
docker ps --format "table {{.Names}}\t{{.Status}}"

# Check specific container health
docker inspect --format='{{.State.Health.Status}}' <container_name>

# View health check logs
docker inspect --format='{{json .State.Health.Log}}' <container_name> | jq
```

#### 3. Check Port Conflicts
```bash
# Check if port is already in use
sudo netstat -tulpn | grep <port_number>

# On Windows/WSL
netstat -ano | findstr <port_number>

# Kill process using the port (if needed)
sudo kill -9 <PID>
```

#### 4. Check Resource Usage
```bash
# Check container resource usage
docker stats <container_name>

# Check system resources
df -h          # Disk space
free -h        # Memory
top            # CPU usage
```

### Solutions

#### Restart Services
```bash
# Restart shared services
./ez shared restart

# Restart Laravel app
./ez laravel restart {app_name} {environment}

# Force recreate containers
./ez shared down
./ez shared deploy
```

#### Clean Up and Rebuild
```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes (CAUTION: data loss)
docker volume prune

# Full system cleanup (CAUTION)
docker system prune -a
```

---

## Input Validation Errors

### Problem
Getting "Invalid app name", "Invalid environment", or similar validation errors.

### Cause
Input doesn't match the required format.

### Validation Rules

#### App Names
- **Pattern**: Alphanumeric, hyphens, underscores only
- **Regex**: `^[a-zA-Z0-9_-]+$`
- **Max Length**: 64 characters
- **Examples**:
  - ✅ Valid: `my-app`, `test_app`, `app123`
  - ❌ Invalid: `my@app`, `app space`, `app;rm`

#### Environments
- **Pattern**: Exact match only
- **Valid Values**: `dev`, `test`, `staging`, `production`
- **Examples**:
  - ✅ Valid: `dev`, `test`, `staging`, `production`
  - ❌ Invalid: `prod`, `development`, `local`, `qa`

#### Database Names
- **Pattern**: Alphanumeric and underscores only (no hyphens)
- **Regex**: `^[a-zA-Z0-9_]+$`
- **Max Length**: 64 characters
- **Examples**:
  - ✅ Valid: `myapp_db`, `test123`, `app_test_2024`
  - ❌ Invalid: `my-app`, `app@db`, `app db`

#### Usernames
- **Pattern**: Alphanumeric and underscores only
- **Regex**: `^[a-zA-Z0-9_]+$`
- **Max Length**: 32 characters
- **Examples**:
  - ✅ Valid: `appuser`, `user_123`, `test2024`
  - ❌ Invalid: `user-name`, `user@host`, `user.name`

### Solution
Rename your app/database/user to match the validation rules above.

---

## Git Repository Issues

### Problem
Can't clone repository, wrong branch, or authentication failures.

### Solutions

#### 1. Verify Git URL
```bash
# Check configured Git URL
cat apps/{app_name}/env/app.env | grep GIT_URL

# Test Git URL manually
git ls-remote {GIT_URL}
```

#### 2. Check Branch Name
```bash
# Check configured branch
cat apps/{app_name}/env/{environment}.env | grep GIT_BRANCH

# List available branches
git ls-remote --heads {GIT_URL}
```

#### 3. SSH Key Configuration
For `git@` URLs, ensure SSH keys are configured:

```bash
# Check SSH key exists
ls -la ~/.ssh/

# Test SSH connection to GitHub
ssh -T git@github.com

# Test SSH connection to GitLab
ssh -T git@gitlab.com

# Add SSH key if needed
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub  # Add this to GitHub/GitLab
```

#### 4. HTTPS Authentication
For `https://` URLs:

```bash
# Configure Git credentials
git config --global credential.helper store

# Or use personal access token
# GitHub: Settings → Developer settings → Personal access tokens
# GitLab: Settings → Access Tokens
```

#### 5. Repository Access Permissions
Verify you have access to the repository:
- Check repository exists
- Verify you're a collaborator
- Check organization/team permissions

---

## Build Cache Issues

### Problem
Code changes not reflected after rebuild, or old code still running.

### Cause
Docker is using cached layers from previous builds.

### Solutions

#### 1. Force Rebuild Without Cache
```bash
# For shared services
docker-compose -f docker/compose-shared.yml build --no-cache

# For Laravel apps
cd apps/{app_name}
docker-compose -f ../../template/compose-laravel.yml build --no-cache
```

#### 2. Remove Old Images
```bash
# List images
docker images

# Remove specific image
docker rmi <image_name>

# Remove all unused images
docker image prune -a
```

#### 3. Clear Build Cache
```bash
# Clear Docker build cache
docker builder prune

# Clear all build cache (CAUTION)
docker builder prune -a
```

#### 4. Verify Code is Updated
```bash
# Check source code in container
docker exec <container_name> ls -la /var/www/html

# Check file modification times
docker exec <container_name> stat /var/www/html/app/Http/Controllers/Controller.php
```

---

## Port Already in Use

### Problem
Error: "Port is already allocated" or "Address already in use".

### Cause
Another process is using the port you're trying to assign.

### Solutions

#### 1. Find What's Using the Port
```bash
# Linux/WSL
sudo netstat -tulpn | grep :{port}
sudo lsof -i :{port}

# Windows PowerShell
netstat -ano | findstr :{port}
```

#### 2. Kill the Process
```bash
# Linux/WSL
sudo kill -9 <PID>

# Windows
taskkill /PID <PID> /F
```

#### 3. Change the Port
Edit the environment file:
```bash
# Edit the env file
nano apps/{app_name}/env/{environment}.env

# Change APP_PORT to an available port
APP_PORT=7001  # or any available port

# Redeploy
./ez laravel deploy {app_name} {environment}
```

#### 4. Stop Conflicting Container
```bash
# List all containers using ports
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Stop conflicting container
docker stop <container_name>
```

---

## Nginx Configuration Issues

### Problem
502 Bad Gateway, 404 errors, or Nginx won't start.

### Diagnosis

#### 1. Check Nginx Logs
```bash
# Nginx Proxy Manager logs
docker logs ez-docker-for-laravel-nginx-pm-1

# Laravel app Nginx logs
docker exec <laravel_container> cat /var/log/nginx/error.log
```

#### 2. Test Nginx Configuration
```bash
# Test configuration syntax
docker exec <container_name> nginx -t

# Reload Nginx
docker exec <container_name> nginx -s reload
```

#### 3. Check PHP-FPM
```bash
# Check PHP-FPM is running
docker exec <laravel_container> ps aux | grep php-fpm

# Check PHP-FPM logs
docker exec <laravel_container> cat /var/log/php/errors.log
```

### Solutions

#### 502 Bad Gateway
Usually means PHP-FPM is not running or not accessible:
```bash
# Restart container
./ez laravel restart {app_name} {environment}

# Check PHP-FPM socket
docker exec <laravel_container> ls -la /var/run/php/
```

#### 404 Not Found
Check document root and file permissions:
```bash
# Verify files exist
docker exec <laravel_container> ls -la /var/www/html

# Check permissions
docker exec <laravel_container> ls -la /var/www/html/public
```

---

## Performance Issues

### Problem
Slow response times, high CPU/memory usage.

### Diagnosis

#### 1. Check Resource Usage
```bash
# Container stats
docker stats

# System resources
htop  # or top
```

#### 2. Check OPcache Status
```bash
# Verify OPcache is enabled
docker exec <laravel_container> php -i | grep opcache

# Check OPcache settings
docker exec <laravel_container> cat /usr/local/etc/php/conf.d/opcache.ini
```

#### 3. Check Database Performance
```bash
# MySQL slow query log
docker exec ez-docker-for-laravel-mysql8-1 mysql -uroot -p{password} -e "SHOW VARIABLES LIKE 'slow_query%';"

# Check running queries
docker exec ez-docker-for-laravel-mysql8-1 mysql -uroot -p{password} -e "SHOW PROCESSLIST;"
```

### Solutions

#### 1. Optimize OPcache
For production, ensure `OPCACHE_VALIDATE_TIMESTAMPS=0` in environment file.

#### 2. Increase Resources
Edit `docker-compose.yml` to add resource limits:
```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
```

#### 3. Database Optimization
```bash
# Optimize tables
docker exec ez-docker-for-laravel-mysql8-1 mysqlcheck -uroot -p{password} --optimize --all-databases

# Analyze tables
docker exec ez-docker-for-laravel-mysql8-1 mysqlcheck -uroot -p{password} --analyze --all-databases
```

---

## Getting More Help

If you're still experiencing issues:

1. **Check Logs**: Always start with container logs
   ```bash
   docker logs <container_name> --tail 100
   ```

2. **Health Checks**: Verify service health
   ```bash
   docker ps --format "table {{.Names}}\t{{.Status}}"
   ```

3. **Documentation**:
   - [Health Check Monitoring](HEALTH_CHECKS.md)
   - [Security Documentation](../SECURITY.md)

4. **Community Support**:
   - [GitHub Issues](https://github.com/MansourM/ez-docker-for-laravel/issues)
   - [GitHub Discussions](https://github.com/MansourM/ez-docker-for-laravel/discussions)

5. **Contact**:
   - Email: sm.mirbehbahani@gmail.com
   - GitHub: [@MansourM](https://github.com/MansourM)

---

**Last Updated**: November 12, 2024
