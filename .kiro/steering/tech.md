# Technology Stack

## Core Technologies

- **Shell Scripting**: Bash 4.0+ for all automation scripts
- **CLI Framework**: Bashly for command-line interface generation
- **Containerization**: Docker and Docker Compose for service orchestration
- **Web Server**: Nginx with PHP-FPM
- **Database**: MySQL 8.0
- **PHP**: Version 8.2 with essential Laravel extensions

## Build System

### CLI Generation
The main `ez` script is generated from `src/bashly.yml` using Bashly:
```bash
# Generate the CLI script (requires Bashly installation)
bashly generate
```

### Docker Images
- Multi-stage Dockerfiles for optimized production builds
- Separate configurations for dev/test/staging/production environments
- Builder stage includes Node.js 20 for asset compilation

## Common Commands

### Project Setup
```bash
# Install Docker (if needed)
sudo ./ez docker install

# Initialize Laravel app structure
sudo ./ez laravel new

# Deploy shared services (Nginx PM, MySQL, phpMyAdmin)
sudo ./ez shared deploy

# Deploy Laravel application
sudo ./ez laravel deploy <app_name> <environment>
```

### Container Management
```bash
# Shared services
sudo ./ez shared start|stop|restart|down

# Laravel applications
sudo ./ez laravel start|stop|restart|down <app_name> <environment>
```

### Testing
```bash
# Run all tests (requires WSL/Linux)
cd test && ./run_simple_tests.sh

# Run specific test categories
./run_unit_tests.sh
./run_integration_tests.sh
./run_security_tests.sh
```

## Development Dependencies

- **Testing**: Approvals.bash framework for approval testing
- **Node.js**: Version 20 for asset compilation
- **Composer**: PHP dependency management
- **Git**: Version control and deployment source

## Environment Requirements

- **OS**: Debian-based systems (tested on Ubuntu 22.04.3 LTS)
- **Shell**: Bash 4.0+ (required for associative arrays)
- **Permissions**: sudo access required for Docker operations
- **Ports**: Dynamic port assignment starting from 7000 (dev), 8000 (test)