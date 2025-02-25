1. dont forget to uncomment reverb/other needed parts from supervisord.conf
2. create proxy hosts through nginx-pm
3. currently there is a bug in nginx-pm https://github.com/NginxProxyManager/nginx-proxy-manager/pull/4262
4. manually edit your proxy host conf file, should look sth like this
```
map $http_x_forwarded_proto $laravel_proto {
    default $scheme;
    ~. $http_x_forwarded_proto;
}

map $scheme $hsts_header {
    https   "max-age=63072000; preload";
}

server {
  set $forward_scheme http;
  set $server         "andropay-crm_dev";
  set $port           80;

  listen 80;
listen [::]:80;

listen 443 ssl http2;
listen [::]:443 ssl http2;

  server_name dev.andropay.xyz;

  # Let's Encrypt SSL
  include conf.d/include/letsencrypt-acme-challenge.conf;
  include conf.d/include/ssl-ciphers.conf;
  ssl_certificate /etc/letsencrypt/live/npm-4/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/npm-4/privkey.pem;

# Asset Caching
  include conf.d/include/assets.conf;


  # Block Exploits
  include conf.d/include/block-exploits.conf;

  access_log /data/logs/proxy-host-1_access.log proxy;
  error_log /data/logs/proxy-host-1_error.log warn;

    set_real_ip_from 173.245.48.0/20;
    set_real_ip_from 103.21.244.0/22;
    set_real_ip_from 103.22.200.0/22;
    set_real_ip_from 103.31.4.0/22;
    set_real_ip_from 141.101.64.0/18;
    set_real_ip_from 108.162.192.0/18;
    set_real_ip_from 190.93.240.0/20;
    set_real_ip_from 188.114.96.0/20;
    set_real_ip_from 197.234.240.0/22;
    set_real_ip_from 198.41.128.0/17;
    set_real_ip_from 162.158.0.0/15;
    set_real_ip_from 104.16.0.0/13;
    set_real_ip_from 104.24.0.0/14;
    set_real_ip_from 172.64.0.0/13;
    set_real_ip_from 131.0.72.0/22;
    real_ip_header X-Forwarded-For;

  location / {
 
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Scheme $laravel_proto;
    proxy_set_header X-Forwarded-Proto  $laravel_proto;
    proxy_set_header X-Forwarded-For    $remote_addr;
    proxy_set_header X-Real-IP          $remote_addr;
    proxy_pass       http://androcrm_dev:80;

    # Asset Caching
  include conf.d/include/assets.conf;

    
  # Block Exploits
  include conf.d/include/block-exploits.conf;

  }

  # Custom
  include /data/nginx/custom/server_proxy[.]conf;
}
```
- then enter your nginx-pm container and restart by `nginx -s reload`
5. if using reverb dont forget to ad proxy host for wss with correct inside port (8080 usually)
6. dont forget to add ssl and http2 support via nginxpm
