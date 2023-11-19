### Error and bugs
* [ ] 


WARN[0066] Found orphan containers ([ez-docker-for-laravel-laravel-builder-1 portainer ez-docker-for-laravel-phpmyadmin-1 ez-docker-for-laravel-mysql8-1 ez-docker-for-laravel-nginx-pm-1]) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.
WARN[0000] Found orphan containers ([ez-docker-for-laravel-laravel-server-1 ez-docker-for-laravel-laravel-builder-1]) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.



### Read

* laravel optimize vs manual one by one suggested by docs
* how can i access a container in local only?
* supervisor


### Useful commands

```cli
netstat -nlptu
sudo su
docker exec -t -i <containerId> /bin/bash
sudo resolvectl status
sudo resolvectl dns eth0 1.1.1.1 8.8.8.8
sudo resolvectl dns eth0 10.202.10.202 10.202.10.102
sudo resolvectl dns eth0 8.8.8.8 8.8.4.4 --set-dns
```


### better readme

- [x] use tables
- [x] show what php plugins are installed
- mention that i run npm run production
- explain why no volumes for laravel
- add FAQ
- explain nginx proxy manager and how to use let's encrypt
- wiki
