<div align="center">
<img src="image/ez-docker-for-laravel.png" alt="logo" width="412" height="128" />
  <!--<h1>EZ Docker For Laravel</h1>-->
  <p>easy to set up, robust and production ready environment for Laravel using Docker, Docker Compose and bash script.</p>
  <p>currently these scripts are debian based and tested on ubuntu 22.04.3 live Server</p>
</div>

<br />

<!-- About the Project -->

## :star2: About the Project
Work in Progress, this is not in a usasble state RN


<!-- Getting Started -->

## :toolbox: Getting Started

<!-- Prerequisites -->
#### :bangbang: Prerequisites

git
```cli
git --version
```

1. clone the repository
```cli 
sudo git clone https://github.com/MansourM/ez-docker-for-laravel.git
cd ez-docker-for-laravel
sudo chmod +x ez.sh
```

2. install dokcer engine
```cli
sudo ./ez.sh docker:install
```

3. create and edit your `.env` file
```cli
sudo cp .env.example .env
sudo nano .env
```

4. deploy common service containers (nginx, mysql, pma, portainer)
```cli
sudo ./ez.sh shared:deploy
```

5. deploy laravel container
```cli
sudo ./ez.sh laravel:deploy
```

:tada:
```
now you website is running at <your_ip_address>:<laravel_port_in_env>
```

<!-- Other Commands -->

## :eyes: Other Commands

show all commands
```cli
sudo ./ez.sh --help
```

uninstall docker engine
```cli
sudo ./ez.sh docker:uninstall
```
removes all images, containers, and volumes (You have to delete any edited configuration files manually)
```cli
sudo ./ez.sh docker:remove
```

stop shared containers
```cli
sudo ./ez.sh shared:stop
```

start shared containers
```cli
sudo ./ez.sh shared:start
```

stop laravel container
```cli
sudo ./ez.sh laravel:stop
```

start laravel container
```cli
sudo ./ez.sh laravel:start
```

##### .env variable examples
```env
PORT_DNS=7011
PORT_NGINX_PM=7022
PORT_PMA=7033
PORT_PORTAINER=7044
PORT_LARAVEL=7777
ROOT_FOLDER_NAME=ez-docker-for-laravel
GIT_URL=https://github.com/MansourM/example.git
GIT_BRANCH=dev
```
you can use this format to avoid entering username and password every time you clone the repo
```env
GIT_URL=https://username:password@github.com/MansourM/example.git
```

<!-- Roadmap -->

## :compass: Changes from Parent / Roadmap

- [ ] test


<!-- Known Issues -->

## :warning: Known Issues



<!-- Contributing -->

## :wave: Contributing

Contributions are always welcome!

<!-- License -->

## :warning: License

Distributed under the GNU GPL V2 License.


<!-- Contact -->

## :handshake: Contact

Seyed Mansour Mirbehbahani - sm.mirbehbahani@gmail.com

<!-- Acknowledgments -->

## :gem: Acknowledgements

- [Awesome Readme Template](https://github.com/Louis3797/awesome-readme-template)
- [Bash Boilerplate](https://github.com/xwmx/bash-boilerplate)
