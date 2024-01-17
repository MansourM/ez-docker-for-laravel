<div align="center">
<img src="image/ez-docker-for-laravel.png" alt="EZ Docker For Laravel" width="412" height="128" />

  <p>easy to set up, robust and production ready environment for Laravel using Docker, Docker Compose and bash script.</p>
  <p>currently these scripts are debian based and tested on ubuntu 22.04.3 live Server</p>
</div>

<!-- About the Project -->

## <h1>EZ Docker For Laravel</h1>
EZ Docker For Laravel is a set of scripts designed to create an easy-to-set-up, robust, and production-ready environment for Laravel using Docker, Docker Compose, and bash scripts.

*Currently, the scripts are successfully working in test and staging environments, and I plan to deploy them in production soon.*

<!-- Prerequisites -->
## :bangbang: Prerequisites

Ensure that you have Ubuntu and Git installed:

```bash
git --version
```

<!-- Getting Started -->

## :toolbox: Getting Started


1. Clone the repository using the following command:
```bash 
sudo git clone https://github.com/MansourM/ez-docker-for-laravel.git && cd ez-docker-for-laravel
sudo chmod +x ez
```

2. create and edit your `.env` file
```bash
sudo cp .env.example .env
sudo nano .env
```

2.1. install dokcer engine (Optional, only if not installed already)
```bash
sudo ./ez docker install
```

3. deploy common service containers (nginx, mysql, pma, portainer)
```bash
sudo ./ez all deploy
```



:tada:
**now your website is running at `<your_ip_address>:<laravel_port_in_env>`**

## :memo: .env variables needed for deployment
you need to add these to your laravel `.env` file
```env
PORT_LARAVEL=8000
PORT_NGINX_PM=8011
PORT_PMA=8022
PORT_PORTAINER=8033
ROOT_FOLDER_NAME=ez-docker-for-laravel
GIT_URL=https://github.com/MansourM/example.git
GIT_BRANCH=dev
DB_ROOT_PASSWORD=
SHARED_NETWORK_NAME=ez-shared-network
```
You can use this format to include your credentials directly in the URL, avoiding the need to enter them each time you clone the repository.
```env
GIT_URL=https://username:password@github.com/MansourM/example.git
```

## :bulb: Additional Info
Nginx Proxymanager default login information:

| Username            | Password  |
|---------------------|-----------|
| admin@example.com   | changeme  |

<!-- Other Commands -->

## :eyes: Other Commands

| Command                      | Description                                                                                                |
|------------------------------|------------------------------------------------------------------------------------------------------------|
| `sudo ./ez --help`           | Shows all commands                                                                                         |
| `sudo ./ez docker install`   | Adds the Docker repository to APT sources and then installs the Docker engine.                             |
| `sudo ./ez docker uninstall` | Uninstalls the Docker engine.                                                                              |
| `sudo ./ez docker remove`    | Removes all images, containers, and volumes. (You have to delete any edited configuration files manually.) |
| `sudo ./ez shared deploy`    | Builds and runs shared service containers (Nginx, MySQL, phpMyAdmin, Portainer).                           |
| `sudo ./ez shared start`     | Starts shared service containers.                                                                          |
| `sudo ./ez shared stop`      | Stops shared service containers.                                                                           |
| `sudo ./ez shared restart`   | Restarts shared service containers.                                                                        |
| `sudo ./ez shared down`      | Removes shared service containers.                                                                         |
| `sudo ./ez laravel deploy`   | Clones your Laravel repository, builds its assets, configures it for production, and then starts it.       |
| `sudo ./ez laravel start`    | Starts Laravel container.                                                                                  |
| `sudo ./ez laravel stop`     | Stops Laravel container.                                                                                   |
| `sudo ./ez laravel restart`  | Restarts Laravel container.                                                                                |
| `sudo ./ez laravel down`     | Removes Laravel container.                                                                                 |
| `sudo ./ez all deploy`       | Deploys all containers.                                                                                    |
| `sudo ./ez all start`        | Starts all containers.                                                                                     |
| `sudo ./ez all stop`         | Stops all containers.                                                                                      |
| `sudo ./ez all restart`      | Restarts all containers.                                                                                   |
| `sudo ./ez all down`         | Removes all containers.                                                                                    |

<!-- PHP Extensions -->

## :heavy_plus_sign: PHP Extensions

I have installed the minimum PHP plugins required to run Laravel (marked by ✔) in the container. You should add others based on your project's needs. Add them in `laravel.Dockerfile`.

|         | Name | Explanation |
|---------|------|-------------|
| ✔ | [php8.3-cli](https://www.php.net/manual/en/features.commandline.php) | Command-line interface for PHP. |
| ✔ | [php8.3-curl](https://www.php.net/manual/en/book.curl.php) | cURL library support for PHP. |
| ✔ | [php8.3-mysql](https://www.php.net/manual/en/book.mysql.php) | MySQL database support for PHP. |
| ✔ | [php8.3-mbstring](https://www.php.net/manual/en/book.mbstring.php) | Multibyte string support for PHP. |
| ✔ | [php8.3-xml](https://www.php.net/manual/en/book.xml.php) | XML support for PHP. |
| &cross; | [php8.3-imap](https://www.php.net/manual/en/book.imap.php) | IMAP support for PHP. |
| &cross; | [php8.3-dev](https://www.php.net/manual/en/intro.setup.php) | Development files for PHP. |
| &cross; | [php8.3-pgsql](https://www.php.net/manual/en/book.pgsql.php) | PostgreSQL database support for PHP. |
| &cross; | [php8.3-sqlite3](https://www.php.net/manual/en/book.sqlite3.php) | SQLite3 database support for PHP. |
| &cross; | [php8.3-gd](https://www.php.net/manual/en/book.image.php) | GD library support for PHP. |
| &cross; | [php8.3-zip](https://www.php.net/manual/en/book.zip.php) | ZIP archive support for PHP. |
| &cross; | [php8.3-bcmath](https://www.php.net/manual/en/book.bc.php) | BCMath arbitrary precision mathematics support for PHP. |
| &cross; | [php8.3-soap](https://www.php.net/manual/en/book.soap.php) | SOAP support for PHP. |
| &cross; | [php8.3-intl](https://www.php.net/manual/en/book.intl.php) | Internationalization support for PHP. |
| &cross; | [php8.3-readline](https://www.php.net/manual/en/book.readline.php) | Readline library support for PHP. |
| &cross; | [php8.3-ldap](https://www.php.net/manual/en/book.ldap.php) | LDAP support for PHP. |
| &cross; | [php8.3-msgpack](https://www.php.net/manual/en/book.msgpack.php) | MessagePack support for PHP. |
| &cross; | [php8.3-igbinary](https://www.php.net/manual/en/book.igbinary.php) | Igbinary support for PHP. |
| &cross; | [php8.3-redis](https://www.php.net/manual/en/book.redis.php) | Redis support for PHP. |
| &cross; | [php8.3-swoole](https://www.php.net/manual/en/book.swoole.php) | Swoole extension for PHP. |
| &cross; | [php8.3-memcached](https://www.php.net/manual/en/book.memcached.php) | Memcached support for PHP. |
| &cross; | [php8.3-pcov](https://github.com/krakjoe/pcov) | Code coverage driver for PHP. |
| &cross; | [php8.3-xdebug](https://xdebug.org/docs/) | Xdebug support for PHP. |
| &cross; | [php8.3-imagick](https://www.php.net/manual/en/book.imagick.php) | ImageMagick extension for PHP. |


<!-- Roadmap -->

## :compass: Roadmap

- [ ] profiles?
- [ ] refactor file names group/start by env/type
- [ ] add CI/CD pipeline/hooks
- [ ] warn if APP_DEBUG=true
- [ ] add a production mode and a test (staging) mode based on APP_DEBUG value
- [ ] add merge/includes for compose file for different modes (production, staging, development, etc? )
- [ ] mark project as production ready when 1 month of testing in production is done.
- [ ] add local source (currently only git is supported)
- [ ] add suggested configuration files (php, mysql, nginx, etc...)
- [ ] explain http/https in nginxpm

<!-- Maybe -->

## :compass: TODO (Maybe)

- [ ] Implement a GUI (optional dashboard).
- [ ] Add more (modular) services (e.g., Redis, Memcached).
- [ ] Integrate a DNS service.
- [ ] Enhance shell with proper subcommands.


<!-- Known Issues -->

## :warning: Known Issues

- While building node_modules (`npm i`) in the builder, a warning may appear: `MaxListenersExceededWarning: Possible EventEmitter memory leak detected. 11 data listeners added to [TLSSocket]. Use emitter.setMaxListeners() to increase limit`. This warning does not seem to affect functionality.
- Symbols in password like`()` seems to break .env reader function in the shell script

<!-- Contributing -->

## :wave: Contributing

Contributions are always welcome! Feel free to fork the project and submit a pull request.

<!-- License -->

## :warning: License

This project is licensed under the GNU GPL V2 License.


<!-- Contact -->

## :handshake: Contact

Seyed Mansour Mirbehbahani - [sm.mirbehbahani@gmail.com](mailto:sm.mirbehbahani@gmail.com)

<!-- Acknowledgments -->

## :gem: Acknowledgements

- [Awesome Readme Template](https://github.com/Louis3797/awesome-readme-template)
