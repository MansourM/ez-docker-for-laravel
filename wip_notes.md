### Error and bugs
* [ ] 


WARN[0066] Found orphan containers ([ez-docker-for-laravel-laravel-builder-1 portainer ez-docker-for-laravel-phpmyadmin-1 ez-docker-for-laravel-mysql8-1 ez-docker-for-laravel-nginx-pm-1]) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.
WARN[0000] Found orphan containers ([ez-docker-for-laravel-laravel-server-1 ez-docker-for-laravel-laravel-builder-1]) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.


# Stop all running containers
sudo docker stop $(sudo docker ps -q)

# Remove all containers
sudo docker rm $(sudo docker ps -aq)
sudo docker ps -a

### Read

* laravel optimize vs manual one by one suggested by docs
* how can i access a container in local only?
* supervisor


### Useful commands
------------
git config --global http.postBuffer 157286400

```cli
netstat -nlptu
sudo su
docker exec -it <containerId> /bin/bash
sudo resolvectl status
sudo resolvectl revert eth0
sudo nano /etc/resolvconf/resolv.conf.d/head
sudo resolvectl dns eth0 1.1.1.1 8.8.8.8
sudo resolvectl dns eth0 10.202.10.202 10.202.10.102
sudo resolvectl dns eth0 178.22.122.100 185.51.200.2
sudo resolvectl dns eth0 178.22.122.100 10.202.10.202
sudo resolvectl dns ens33 1.1.1.1 8.8.8.8
sudo resolvectl dns ens33 10.202.10.202 10.202.10.102
sudo resolvectl dns eth0 8.8.8.8 8.8.4.4 --set-dns

-------------------
sudo nano /etc/resolvconf/resolv.conf.d/head

nameserver 178.22.122.100
nameserver 185.51.200.2

nameserver 10.202.10.202
nameserver 10.202.10.102

nameserver 185.55.225.25
nameserver 185.55.226.26

sudo systemctl stop resolvconf.service
sudo systemctl start resolvconf.service

sudo resolvconf --enable-updates
sudo resolvconf -u
-----------------------
sudo apt update
sudo apt install resolvconf

sudo nano /etc/resolvconf/resolv.conf.d/head

nameserver 8.8.8.8
nameserver 8.8.4.4

sudo systemctl restart resolvconf.service
sudo systemctl restart systemd-resolved.service

sudo systemctl status resolvconf.service

sudo resolvectl status


---------------------------

#ENTRYPOINT ["tail", "-f", "/dev/null"]

----------------
nameserver 178.22.122.100
nameserver 185.51.200.2

nameserver 10.202.10.202
nameserver 10.202.10.102

df -h
sudo apt clean
# which can show disk usage and size of 'Build Cache'
docker system df
# add -f or --force to not prompt for confirmation
docker image prune
# add -f or --force to not prompt for confirmation
docker container prune
```

//LEAKED XD need to reset this
git clone -b "profiles" "https://MansourM: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@github.com/MansourM/digicontract.git" "laravel-test"


### better readme

- [x] use tables
- [x] show what php plugins are installed
- mention that i run npm run production
- explain why no volumes for laravel
- add FAQ
- explain nginx proxy manager and how to use let's encrypt
- wiki
