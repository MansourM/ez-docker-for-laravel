<div align="center">
<img src="image/ez-docker-for-laravel.png" alt="EZ Docker For Laravel" width="412" height="128" />

  <p>easy to set up, robust and production ready environment for Laravel using Docker, Docker Compose and bash script.</p>
  <p>currently these scripts are debian based and tested on ubuntu 22.04.3 live Server</p>
</div>

<!-- About the Project -->

## <h1>EZ Docker For Laravel</h1>
EZ Docker For Laravel provides an easy-to-use, production-ready environment for running Laravel applications using Docker and Docker Compose. It simplifies the deployment process by offering a set of scripts to manage configurations, deploy, and maintain Laravel projects efficiently across various environments, such as test, staging, and production. The software streamlines server setup and management, offering features like support for Nginx, MySQL, and PHP-FPM, as well as additional services and extensions tailored to Laravel's requirements. By following the steps outlined in this readme, you can quickly set up your Laravel project and deploy it for reliable and scalable hosting.

*Currently, the scripts are successfully working in test and staging environments, and I plan to deploy them in production soon.*

<!-- Getting Started -->

## :toolbox: Getting Started


1. Clone the repository using the following command:
   ```bash 
   sudo git clone https://github.com/MansourM/ez-docker-for-laravel.git && cd ez-docker-for-laravel
   ```

-  install docker engine (Optional, only if not installed already)
   ```bash
   sudo ./ez docker install
   ```

2. Initialize your Laravel app
   ```bash
   sudo ./ez laravel new
   ```

3. deploy your shared containers (Nginx, Mysql, PhpMyAdmin)
   ```bash
   sudo ./ez shared deploy
   
4. deploy your laravel project
   ```bash
   sudo ./ez laravel deploy {app_name} {environment}
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

| Command                                         | Description                                                                                                |
|-------------------------------------------------|------------------------------------------------------------------------------------------------------------|
| `sudo ./ez --help`                              | Shows all commands                                                                                         |
| `sudo ./ez docker install`                      | Adds the Docker repository to APT sources and then installs the Docker engine.                             |
| `sudo ./ez docker uninstall`                    | Uninstalls the Docker engine.                                                                              |
| `sudo ./ez docker remove`                       | Removes all images, containers, and volumes. (You have to delete any edited configuration files manually.) |
| `sudo ./ez shared deploy`                       | Builds and runs shared service containers (Nginx, MySQL, phpMyAdmin, Portainer).                           |
| `sudo ./ez shared start`                        | Starts shared service containers.                                                                          |
| `sudo ./ez shared stop`                         | Stops shared service containers.                                                                           |
| `sudo ./ez shared restart`                      | Restarts shared service containers.                                                                        |
| `sudo ./ez shared down`                         | Removes shared service containers.                                                                         |
| `sudo ./ez laravel deploy <app_name> <app_env>` | Clones your Laravel repository, builds its assets, configures it for production, and then starts it.       |
| `sudo ./ez laravel start <app_name> <app_env>`  | Starts Laravel container.                                                                                  |
| `sudo ./ez laravel stop <app_name> <app_env>`   | Stops Laravel container.                                                                                   |
| `sudo ./ez laravel restart <app_name> <app_env>`| Restarts Laravel container.                                                                                |
| `sudo ./ez laravel down <app_name> <app_env>`   | Removes Laravel container.                                                                                 | |

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
- [ ] add docker to sudoers
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


<!-- Known Issues -->

## :warning: Known Issues

- [ ] you need to manually sudo chown -R <host_user> <laravel_storage_volume>

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
- [M.Mahdi Mahmoodian](https://github.com/MMMahmoodian) Help/Review Nginx/FPM setup
- [nginx-php-fpm](https://github.com/jkaninda/nginx-php-fpm) nginx/fpm configuration and dockerfile
