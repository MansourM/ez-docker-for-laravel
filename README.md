<div align="center">
<img src="image/ez-docker-for-laravel.png" alt="EZ Docker For Laravel" width="412" height="128" />

  <p>easy to set up, robust and production ready environment for Laravel using Docker, Docker Compose and bash script.</p>
  <p>currently these scripts are debian based and tested on ubuntu 22.04.3 live Server</p>
</div>

<!-- About the Project -->

## <h1>EZ Docker For Laravel</h1>
EZ Docker For Laravel provides an easy-to-use, production-ready environment for running Laravel applications using Docker and Docker Compose. It simplifies the deployment process by offering a set of scripts to manage configurations, deploy, and maintain Laravel projects efficiently across various environments, such as test, staging, and production. The software streamlines server setup and management, offering features like support for Nginx, MySQL, and PHP-FPM, as well as additional services and extensions tailored to Laravel's requirements. By following the steps outlined in this readme, you can quickly set up your Laravel project and deploy it for reliable and scalable hosting.

*Production-ready and security-hardened. Successfully tested in dev, test, and staging environments.*

<!-- Security Features -->

## :shield: Security Features

EZ Docker For Laravel is production-ready with comprehensive security hardening:

- **SQL Injection Protection** - Validated identifiers, parameterized queries, password sanitization
- **Input Validation** - Strict validation for all user inputs (app names, environments, credentials)
- **Network Security** - Database access restricted to Docker network (172.%.%.%)
- **Docker Security** - Pinned image versions, health checks, no `latest` tags
- **Security Headers** - HSTS, CSP, X-Frame-Options, X-Content-Type-Options, and more
- **Error Handling** - Strict mode (`set -euo pipefail`) in all critical scripts
- **Access Control** - Docker group membership (no root required), minimal privileges

**Security Status**: ✅ Production Ready | 🔒 LOW RISK | 96 tests passing

For complete security documentation, see:
- [SECURITY.md](SECURITY.md) - Security policy, best practices, vulnerability reporting
- [docs/SECURITY_AUDIT.md](docs/SECURITY_AUDIT.md) - Latest security audit report

<!-- Getting Started -->

## :toolbox: Getting Started

### Platform Requirements

**Supported Platforms:**
- **Operating System**: Debian-based Linux distributions
- **Tested On**: Ubuntu 22.04.3 LTS (Live Server)
- **Shell**: Bash 4.0+ (required for associative arrays)
- **Docker**: Docker Engine 20.10+ and Docker Compose V2

**Why Debian/Ubuntu Only?**

This tool is specifically designed and tested for Debian-based systems because:
- Uses APT package manager for Docker installation
- Relies on Debian-specific paths and configurations
- Tested extensively on Ubuntu 22.04.3 LTS
- Shell scripts use bash features available in Debian/Ubuntu

**Windows/macOS Users:**

If you want to use this tool on Windows or macOS, you can:
- **Windows**: Use WSL2 (Windows Subsystem for Linux) with Ubuntu
- **macOS**: Not currently supported (different package managers and paths)

### Prerequisites

**Docker Access Setup:**

This tool requires access to Docker. You have two options:

**Option 1: Add your user to the docker group (Recommended)**
```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Activate the group (or log out and back in)
newgrp docker

# Verify Docker access
docker ps
```

**Option 2: Run with sudo**
```bash
# If you prefer, you can run all commands with sudo
sudo ./ez <command>
```

### Installation Steps

1. Clone the repository:
   ```bash 
   git clone https://github.com/MansourM/ez-docker-for-laravel.git && cd ez-docker-for-laravel
   ```

2. Install Docker engine (Optional, only if not installed already):
   ```bash
   ./ez docker install
   ```

3. Initialize your Laravel app:
   ```bash
   ./ez laravel new
   ```

4. Deploy your shared containers (Nginx, MySQL, phpMyAdmin):
   ```bash
   ./ez shared deploy
   ```
   
5. Deploy your Laravel project:
   ```bash
   ./ez laravel deploy {app_name} {environment}
   ```

## :tada: :tada: :tada:
* **now your website is running at `<your_ip_address>:<APP_PORT>`**
* website is only exposed via `APP_PORT` in `dev` and `test` environments to access the `staging` or `production` website you need to configure them on your domain using npm proxy manager


## :gear: Github actions
You can find examples of GitHub Actions in the `.github.example/workflows` folder. Remember to remove the `.example` from the folder name before using the workflows.

## :bulb: Additional Info
Nginx Proxymanager default login information:

| Username            | Password  |
|---------------------|-----------|
| admin@example.com   | changeme  |

<!-- Other Commands -->

## :eyes: Other Commands

| Command                                    | Description                                                                                                |
|--------------------------------------------|------------------------------------------------------------------------------------------------------------|
| `./ez --help`                              | Shows all commands                                                                                         |
| `./ez docker install`                      | Adds the Docker repository to APT sources and then installs the Docker engine.                             |
| `./ez docker uninstall`                    | Uninstalls the Docker engine.                                                                              |
| `./ez docker remove`                       | Removes all images, containers, and volumes. (You have to delete any edited configuration files manually.) |
| `./ez shared deploy`                       | Builds and runs shared service containers (Nginx, MySQL, phpMyAdmin, Portainer).                           |
| `./ez shared start`                        | Starts shared service containers.                                                                          |
| `./ez shared stop`                         | Stops shared service containers.                                                                           |
| `./ez shared restart`                      | Restarts shared service containers.                                                                        |
| `./ez shared down`                         | Removes shared service containers.                                                                         |
| `./ez laravel deploy <app_name> <app_env>` | Clones your Laravel repository, builds its assets, configures it for production, and then starts it.       |
| `./ez laravel start <app_name> <app_env>`  | Starts Laravel container.                                                                                  |
| `./ez laravel stop <app_name> <app_env>`   | Stops Laravel container.                                                                                   |
| `./ez laravel restart <app_name> <app_env>`| Restarts Laravel container.                                                                                |
| `./ez laravel down <app_name> <app_env>`   | Removes Laravel container.                                                                                 |

**Note:** If you haven't added your user to the docker group, prefix commands with `sudo`.

<!-- PHP Extensions -->

## :heavy_plus_sign: PHP Extensions

I have installed the minimum PHP plugins required to run Laravel (marked by ✔) in the container. You should add others based on your project's needs. Add them in `laravel.Dockerfile`.

|         | Name | Explanation |
|---------|------|-------------|
| ✔ | [php8.2-cli](https://www.php.net/manual/en/features.commandline.php) | Command-line interface for PHP. |
| ✔ | [php8.2-curl](https://www.php.net/manual/en/book.curl.php) | cURL library support for PHP. |
| ✔ | [php8.2-mysql](https://www.php.net/manual/en/book.mysql.php) | MySQL database support for PHP. |
| ✔ | [php8.2-mbstring](https://www.php.net/manual/en/book.mbstring.php) | Multibyte string support for PHP. |
| ✔ | [php8.2-xml](https://www.php.net/manual/en/book.xml.php) | XML support for PHP. |
| &cross; | [php8.2-imap](https://www.php.net/manual/en/book.imap.php) | IMAP support for PHP. |
| &cross; | [php8.2-dev](https://www.php.net/manual/en/intro.setup.php) | Development files for PHP. |
| &cross; | [php8.2-pgsql](https://www.php.net/manual/en/book.pgsql.php) | PostgreSQL database support for PHP. |
| &cross; | [php8.2-sqlite3](https://www.php.net/manual/en/book.sqlite3.php) | SQLite3 database support for PHP. |
| &cross; | [php8.2-gd](https://www.php.net/manual/en/book.image.php) | GD library support for PHP. |
| &cross; | [php8.2-zip](https://www.php.net/manual/en/book.zip.php) | ZIP archive support for PHP. |
| &cross; | [php8.2-bcmath](https://www.php.net/manual/en/book.bc.php) | BCMath arbitrary precision mathematics support for PHP. |
| &cross; | [php8.2-soap](https://www.php.net/manual/en/book.soap.php) | SOAP support for PHP. |
| &cross; | [php8.2-intl](https://www.php.net/manual/en/book.intl.php) | Internationalization support for PHP. |
| &cross; | [php8.2-readline](https://www.php.net/manual/en/book.readline.php) | Readline library support for PHP. |
| &cross; | [php8.2-ldap](https://www.php.net/manual/en/book.ldap.php) | LDAP support for PHP. |
| &cross; | [php8.2-msgpack](https://www.php.net/manual/en/book.msgpack.php) | MessagePack support for PHP. |
| &cross; | [php8.2-igbinary](https://www.php.net/manual/en/book.igbinary.php) | Igbinary support for PHP. |
| &cross; | [php8.2-redis](https://www.php.net/manual/en/book.redis.php) | Redis support for PHP. |
| &cross; | [php8.2-swoole](https://www.php.net/manual/en/book.swoole.php) | Swoole extension for PHP. |
| &cross; | [php8.2-memcached](https://www.php.net/manual/en/book.memcached.php) | Memcached support for PHP. |
| &cross; | [php8.2-pcov](https://github.com/krakjoe/pcov) | Code coverage driver for PHP. |
| &cross; | [php8.2-xdebug](https://xdebug.org/docs/) | Xdebug support for PHP. |
| &cross; | [php8.2-imagick](https://www.php.net/manual/en/book.imagick.php) | ImageMagick extension for PHP. |


<!-- Health Check Monitoring -->

## :heartbeat: Health Check Monitoring

All shared services include built-in health checks for automatic monitoring and recovery.

| Service | Health Check Method | Interval | Timeout | Retries | Start Period |
|---------|-------------------|----------|---------|---------|--------------|
| **Nginx Proxy Manager** | HTTP request to localhost:80 | 30s | 10s | 5 | 30s |
| **MySQL 8** | mysqladmin ping | 30s | 10s | 5 | 30s |
| **phpMyAdmin** | HTTP request to localhost:80 | 30s | 10s | 5 | 30s |

**Monitor service health:**
```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

Docker automatically restarts unhealthy containers, ensuring minimal downtime and continuous availability.

For detailed health check documentation, see [docs/HEALTH_CHECKS.md](docs/HEALTH_CHECKS.md).

<!-- Roadmap -->

## :compass: TODOs

- [ ] say hi!
- [ ] add flag to use default input instead of prompting the user
- [ ] changing GIT_URL in app.env has no effect, will still pull from previous repo
- [ ] make builder stage on volume so we have better caching on it?
- [ ] add text log files
- [ ] mayne merge docker and shared folder? needs better naming or refactor -probably
- [ ] review https://laradock.io/getting-started/
- [ ] review https://github.com/masoudfesahat/laravel-with-docker
- [ ] APP_ENV in laravel.dockerfile is affecting build cache when building different env after each other ----> or not!!!?
- [ ] be more strict on showing passwords in cli? (it is good for convenience though!)
- [ ] add flags like -d on laravel new to go with the default instead of prompting the user, etc
- [ ] image/build cache seems to be effected when service/container name is changed -> research this
- [x] add docker to sudoers (replaced with docker group membership check)
- [ ] add tags to --build then remove orphans
- [ ] better handling of unused/dangling/orphan images/containers
- [ ] explain how to change scripts and generate new a `ez` script with Bashly 
- [ ] mark project as production ready when 1 month of testing in production is done.

<!-- Maybe -->

## :compass: Maybe?

- [ ] Implement a GUI (optional dashboard).
- [ ] Add more (modular) services (e.g., Redis, Memcached).
- [ ] Integrate a DNS service.
- [ ] add local source (currently only git is supported)


<!-- Troubleshooting -->

## :wrench: Troubleshooting

### Common Issues

**Docker Permission Issues**
```bash
sudo usermod -aG docker $USER && newgrp docker
```

**Database Connection Problems**
- Check credentials in `apps/{app_name}/env/{environment}.env`
- Verify database exists: `docker exec ez-docker-for-laravel-mysql8-1 mysql -uroot -p{password} -e "SHOW DATABASES;"`
- Ensure container is running: `docker ps | grep mysql`

**Container Won't Start**
- Check logs: `docker logs <container_name>`
- Verify health: `docker ps --format "table {{.Names}}\t{{.Status}}"`
- Restart: `./ez shared restart` or `./ez laravel restart {app_name} {environment}`

**Input Validation Errors**
- App names: Alphanumeric, hyphens, underscores only (max 64 chars)
- Environments: `dev`, `test`, `staging`, or `production` only
- Database names: Alphanumeric and underscores only (no hyphens)

For complete troubleshooting guide, see [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

<!-- Known Issues -->

## :warning: Known Issues

- [x] having # in DB_PASSWORD will break the script ~~(everything will run but you cant access db as password won't be set properly)~~ **FIXED**: Password sanitization now handles special characters correctly

<!-- Contributing -->

## :wave: Contributing

Contributions are always welcome! Feel free to fork the project and submit a pull request.

<!-- License -->

## :warning: License

This project is licensed under the GNU GPL V2 License.


<!-- Contact -->

## :handshake: Contact

Seyed Mansour Mirbehbahani - [sm.mirbehbahani@gmail.com](mailto:sm.mirbehbahani@gmail.com)

<!-- Documentation -->

## :books: Documentation

- **[Documentation Index](docs/README.md)** - Complete documentation guide
- **[Security Policy](SECURITY.md)** - Security features and vulnerability reporting
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Detailed problem-solving guide
- **[Health Checks](docs/HEALTH_CHECKS.md)** - Service monitoring and recovery
- **[Testing Guide](test/README.md)** - Running and writing tests
- **[Bashly Workflow](docs/BASHLY_WORKFLOW.md)** - Modifying the CLI

<!-- Acknowledgments -->

## :gem: Acknowledgements

- [Awesome Readme Template](https://github.com/Louis3797/awesome-readme-template)
- [M.Mahdi Mahmoodian](https://github.com/MMMahmoodian) Help/Review Nginx/FPM setup
- [nginx-php-fpm](https://github.com/jkaninda/nginx-php-fpm) nginx/fpm configuration and dockerfile
