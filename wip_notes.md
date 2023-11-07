### Error and bugs
* [ ] failed to solve: ubuntu:22.04: failed to do request: Head "https://registry-1.docker.io/v2/library/ubuntu/manifests/22.04": dial tcp: lookup registry-1.docker.io on 127.0.0.1:53: read udp 127.0.0.1:60149->127.0.0.1:53: i/o timeout
* [ ] got this error once while running `docker-compose up -d`: dial tcp: lookup registry-1.docker.io on 127.0.0.1:53: server misbehaving


WARN[0066] Found orphan containers ([ez-docker-for-laravel-laravel-builder-1 portainer ez-docker-for-laravel-phpmyadmin-1 ez-docker-for-laravel-mysql8-1 ez-docker-for-laravel-nginx-pm-1]) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.


### Read
* [ ] https://www.reddit.com/r/technitium/comments/vsw1bq/technitium_dns_server_in_a_production_environment/.
* [ ] https://blog.technitium.com/2017/11/running-dns-server-on-ubuntu-linux.html
* [ ] optimize vs manual one by one


### Useful commands

```cli
netstat -nlptu
sudo su
docker exec -t -i <containerId> /bin/bash
```
