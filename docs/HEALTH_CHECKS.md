# Health Check Monitoring

## Overview

EZ Docker For Laravel implements comprehensive health checks for all shared services to ensure high availability and automatic recovery from failures. Docker's built-in health check mechanism continuously monitors service health and can automatically restart unhealthy containers.

## Health Check Configuration

All health checks are configured in `docker/common-shared.yml` with the following parameters:

### Nginx Proxy Manager

```yaml
healthcheck:
  test: [ "CMD-SHELL", "curl -f http://localhost:80 || exit 1" ]
  interval: 30s
  timeout: 10s
  retries: 5
  start_period: 30s
```

**How it works:**
- Sends an HTTP request to the Nginx service on port 80
- Fails if the service doesn't respond or returns an error
- Allows 30 seconds startup time before health checks begin

### MySQL 8

```yaml
healthcheck:
  test: [ "CMD", "mysqladmin", "ping", "-h", "localhost" ]
  interval: 30s
  timeout: 10s
  retries: 5
  start_period: 30s
```

**How it works:**
- Uses `mysqladmin ping` to verify MySQL is accepting connections
- Checks database availability without requiring authentication
- Ensures database is ready to accept queries

### phpMyAdmin

```yaml
healthcheck:
  test: [ "CMD-SHELL", "curl -f http://localhost:80 || exit 1" ]
  interval: 30s
  timeout: 10s
  retries: 5
  start_period: 30s
```

**How it works:**
- Sends an HTTP request to the phpMyAdmin web interface
- Verifies the web server is responding
- Ensures the interface is accessible

## Health Check Parameters Explained

### Interval (30s)
Time between consecutive health checks. A 30-second interval provides:
- Regular monitoring without excessive overhead
- Quick detection of failures (within 30 seconds)
- Balanced resource usage

### Timeout (10s)
Maximum time to wait for a health check response. A 10-second timeout:
- Allows sufficient time for slow responses
- Prevents indefinite waiting
- Detects hung or frozen services

### Retries (5)
Number of consecutive failures before marking as unhealthy. With 5 retries:
- Prevents false positives from transient issues
- Allows up to 2.5 minutes (5 × 30s) before marking unhealthy
- Balances sensitivity with stability

### Start Period (30s)
Grace period during container startup. A 30-second start period:
- Allows services time to initialize
- Prevents premature failure detection
- Accommodates slow startup processes

## Monitoring Health Status

### View All Container Health

```bash
# Simple status view
docker ps

# Formatted table with health status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Filter only unhealthy containers
docker ps --filter health=unhealthy
```

### Detailed Health Information

```bash
# View full health check details (requires jq)
docker inspect --format='{{json .State.Health}}' <container_name> | jq

# View last 5 health check results
docker inspect --format='{{json .State.Health.Log}}' <container_name> | jq '.[-5:]'

# Check current health status
docker inspect --format='{{.State.Health.Status}}' <container_name>
```

### Health Status Values

- **starting**: Container is in start period, health checks not yet active
- **healthy**: All recent health checks passed
- **unhealthy**: Multiple consecutive health checks failed (reached retry limit)

## Automatic Recovery

### Restart Policies

Services use these restart policies:
- **unless-stopped**: Restart automatically unless explicitly stopped by user
- **always**: Always restart, even after system reboot

### Recovery Process

When a service becomes unhealthy:

1. **Detection**: After 5 consecutive failed health checks (2.5 minutes)
2. **Marking**: Container status changes to "unhealthy"
3. **Restart**: Docker automatically restarts the container
4. **Grace Period**: 30-second start period begins
5. **Monitoring**: Health checks resume after start period

### Recovery Time

Typical recovery timeline:
- **Detection**: 2.5 minutes (5 retries × 30s interval)
- **Restart**: 5-10 seconds (container stop/start)
- **Startup**: 30 seconds (start period)
- **Total**: ~3-4 minutes from failure to recovery

## Manual Health Check Testing

### Test Individual Services

**Nginx Proxy Manager:**
```bash
# From host
docker exec ez-docker-for-laravel-nginx-pm-1 curl -f http://localhost:80

# Expected output: HTML content or HTTP 200 response
```

**MySQL:**
```bash
# From host
docker exec ez-docker-for-laravel-mysql8-1 mysqladmin ping -h localhost

# Expected output: "mysqld is alive"
```

**phpMyAdmin:**
```bash
# From host
docker exec ez-docker-for-laravel-phpmyadmin-1 curl -f http://localhost:80

# Expected output: HTML content or HTTP 200 response
```

### Simulate Failures

For testing purposes, you can simulate service failures:

**Stop a service process (will trigger health check failure):**
```bash
# Stop Nginx inside container (will be detected and restarted)
docker exec <nginx-pm-container> pkill nginx

# Stop MySQL (will be detected and restarted)
docker exec <mysql-container> mysqladmin shutdown
```

**Monitor recovery:**
```bash
# Watch container status in real-time
watch -n 1 'docker ps --format "table {{.Names}}\t{{.Status}}"'
```

## Troubleshooting

### Service Repeatedly Becomes Unhealthy

**Possible causes:**
- Insufficient resources (CPU, memory)
- Network connectivity issues
- Configuration errors
- Database corruption

**Diagnosis:**
```bash
# Check container logs
docker logs <container_name> --tail 100

# Check resource usage
docker stats <container_name>

# Check health check logs
docker inspect --format='{{json .State.Health.Log}}' <container_name> | jq
```

### Health Checks Never Pass

**Possible causes:**
- Service not starting properly
- Health check command incorrect
- Timeout too short for slow services

**Diagnosis:**
```bash
# Check if service is actually running
docker exec <container_name> ps aux

# Manually run health check command
docker exec <container_name> <health-check-command>

# Check startup logs
docker logs <container_name> --since 5m
```

### False Positives (Healthy but Not Working)

**Possible causes:**
- Health check too simple (only checks if process responds)
- Application-level issues not detected by health check

**Solution:**
- Enhance health checks to test actual functionality
- Add application-level monitoring
- Implement custom health check endpoints

## Best Practices

### 1. Monitor Health Check Logs

Regularly review health check logs to identify patterns:
```bash
# Check for frequent failures
docker inspect --format='{{json .State.Health.Log}}' <container_name> | jq '[.[] | select(.ExitCode != 0)]'
```

### 2. Adjust Parameters for Your Environment

Consider adjusting health check parameters based on:
- **High-traffic environments**: Shorter intervals for faster detection
- **Resource-constrained systems**: Longer intervals to reduce overhead
- **Slow-starting services**: Longer start periods

### 3. Implement Application-Level Health Checks

For Laravel applications, consider adding custom health check endpoints:
```php
// routes/web.php
Route::get('/health', function () {
    // Check database connection
    DB::connection()->getPdo();
    
    // Check cache
    Cache::get('health-check');
    
    return response()->json(['status' => 'healthy']);
});
```

### 4. Set Up External Monitoring

Complement Docker health checks with external monitoring:
- **Uptime monitoring**: Services like UptimeRobot, Pingdom
- **Application monitoring**: New Relic, Datadog
- **Log aggregation**: ELK stack, Splunk

### 5. Document Custom Health Checks

If you add custom health checks:
- Document the check logic
- Explain expected behavior
- Note any dependencies
- Specify failure scenarios

## Integration with CI/CD

### GitHub Actions Example

```yaml
- name: Wait for services to be healthy
  run: |
    timeout 300 bash -c 'until docker ps | grep -q "healthy"; do sleep 5; done'
    
- name: Verify all services healthy
  run: |
    docker ps --filter health=unhealthy --format "{{.Names}}" | \
    if read name; then echo "Unhealthy: $name"; exit 1; fi
```

### Deployment Scripts

```bash
#!/bin/bash
# Wait for services to become healthy after deployment

MAX_WAIT=300  # 5 minutes
ELAPSED=0

while [ $ELAPSED -lt $MAX_WAIT ]; do
    UNHEALTHY=$(docker ps --filter health=unhealthy --format "{{.Names}}")
    
    if [ -z "$UNHEALTHY" ]; then
        echo "All services healthy!"
        exit 0
    fi
    
    echo "Waiting for services: $UNHEALTHY"
    sleep 10
    ELAPSED=$((ELAPSED + 10))
done

echo "Timeout: Services did not become healthy"
exit 1
```

## Security Considerations

### Health Check Endpoints

- Health check endpoints should not expose sensitive information
- Avoid including authentication details in health check commands
- Use read-only operations for health checks
- Limit health check access to localhost when possible

### Resource Limits

Health checks consume resources:
- Monitor CPU/memory usage of health check processes
- Adjust intervals if health checks cause performance issues
- Consider disabling health checks in development if needed

## Further Reading

- [Docker Health Check Documentation](https://docs.docker.com/engine/reference/builder/#healthcheck)
- [Docker Compose Health Check](https://docs.docker.com/compose/compose-file/compose-file-v3/#healthcheck)
- [Best Practices for Health Checks](https://docs.docker.com/config/containers/start-containers-automatically/)
