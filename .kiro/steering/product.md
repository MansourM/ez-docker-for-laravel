# Product Overview

EZ Docker For Laravel is a production-ready Docker environment management tool for Laravel applications. It provides an easy-to-use CLI interface built with Bashly that simplifies deployment, configuration, and maintenance of Laravel projects across multiple environments (dev, test, staging, production).

## Key Features

- **Multi-environment support**: Separate configurations for dev, test, staging, and production
- **Shared services**: Centralized Nginx Proxy Manager, MySQL 8, and phpMyAdmin containers
- **Automated deployment**: Git-based deployment with branch management per environment
- **Database management**: Automatic database and user creation per application/environment
- **Port management**: Automatic port assignment to prevent conflicts
- **Production-ready**: Optimized Docker configurations with proper security and performance settings

## Target Users

- Laravel developers needing consistent deployment environments
- DevOps teams managing multiple Laravel applications
- Teams requiring isolated staging and production environments
- Developers wanting simplified Docker management for Laravel projects

## Current Status

- Successfully tested in test and staging environments
- Production deployment planned
- Debian-based, tested on Ubuntu 22.04.3 LTS