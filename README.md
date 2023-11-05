<div align="center">
<img src="image/ez-docker-for-laravel.png" alt="logo" width="412" height="128" />
  <!--<h1>EZ Docker For Laravel</h1>-->
  <p>easy to set up, robust and production ready environment for Laravel using Docker, Docker Compose and bash script.</p>
</div>

<br />

<!-- About the Project -->

## :star2: About the Project
Work in Progress, this is not in a usasble state RN


<!-- Getting Started -->

## :toolbox: Getting Started


<!-- Prerequisites -->
### :bangbang: Prerequisites

git
docker


<!-- Usage -->

## :eyes: Usage

```cli
docker compose -f docker-compose-builder.yml up --build
docker compose -f docker-compose-common.yml up --build
docker compose -f docker-compose-laravel.yml up --build
git clone -b <branch> <remote_repo> src
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

* [ ] WIP.


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
