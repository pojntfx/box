# Traefik

Traefik (pronounced traffic) is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy[^note].

```shell
ssh jean@jeans-box.alphahorizon.io

sudo mkdir -p /etc/traefik
sudo tee /etc/traefik/traefik.yaml<<'EOT'
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entrypoint:
          to: websecure
          scheme: https

  websecure:
    address: ":443"

  sshalt:
    address: ":2222"

  websecurealt:
    address: ":8443"

providers:
  file:
    filename: /etc/traefik/services.yaml
    watch: true

api:
  dashboard: true

certificatesResolvers:
  letsencrypt:
    acme:
      email: jean@example.com
      storage: /var/lib/traefik/acme.json
      httpChallenge:
        entryPoint: web

log:
  level: INFO
EOT

sudo tee /etc/traefik/services.yaml<<'EOT'
tcp:
  routers:
      ssh:
      entryPoints:
        - websecurealt
      rule: HostSNI(`*`)
      service: ssh
    giteaSSH:
      entryPoints:
        - sshalt
      rule: HostSNI(`*`)
      service: giteaSSH
    sshOverTLS:
      entryPoints:
        - websecure
      rule: HostSNI(`ssh.jeans-box.alphahorizon.io`)
      service: ssh
      tls:
        certResolver: letsencrypt
        domains:
          - main: ssh.jeans-box.alphahorizon.io
  services:
    ssh:
      loadBalancer:
        servers:
          - address: localhost:22
    giteaSSH:
      loadBalancer:
        servers:
          - address: localhost:3022

http:
  routers:
    dashboard:
      rule: Host(`traefik.jeans-box.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: traefik.jeans-box.alphahorizon.io
      service: api@internal
      entryPoints:
        - websecure
      middlewares:
        - dashboard
    cockpit:
      rule: Host(`cockpit.jeans-box.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: cockpit.jeans-box.alphahorizon.io
      service: cockpit
      entryPoints:
        - websecure
    gitea:
      rule: Host(`gitea.jeans-box.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: gitea.jeans-box.alphahorizon.io
      service: gitea
      entryPoints:
        - websecure
    dex:
      rule: Host(`dex.jeans-box.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: dex.jeans-box.alphahorizon.io
      service: dex
      entryPoints:
        - websecure
    liwasc:
      rule: Host(`liwasc.jeans-box.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: liwasc.jeans-box.alphahorizon.io
      service: liwasc
      entryPoints:
        - websecure
    bofied:
      rule: Host(`bofied.jeans-box.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: bofied.jeans-box.alphahorizon.io
      service: bofied
      entryPoints:
        - websecure

  middlewares:
    dashboard:
      basicauth:
        users:
          - "jean:$apr1$dYdt8Zrl$TsEfzaedPGyjdrDk8EfRN." # htpasswd -nb jean asdf

  services:
    cockpit:
      loadBalancer:
        serversTransport: cockpit
        servers:
          - url: https://localhost:9090
    gitea:
      loadBalancer:
        servers:
          - url: http://localhost:3000
    dex:
      loadBalancer:
        servers:
          - url: http://localhost:5556
    liwasc:
      loadBalancer:
        servers:
          - url: http://localhost:15124
    bofied:
      loadBalancer:
        servers:
          - url: http://localhost:15256

  serversTransports:
    cockpit:
      insecureSkipVerify: true
EOT

sudo mkdir -p /var/lib/traefik

sudo podman run -d --restart=always --label "io.containers.autoupdate=image" --net=host -v /var/lib/traefik/:/var/lib/traefik -v /etc/traefik/:/etc/traefik --name traefik traefik
sudo podman generate systemd --new traefik | sudo tee /lib/systemd/system/traefik.service

sudo systemctl daemon-reload
sudo systemctl enable --now traefik

sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --reload

curl -Lu jean:asdf https://traefik.jeans-box.alphahorizon.io/ # Test the Traefik dashboard
ssh -p 8443 jean@jeans-box.alphahorizon.io # Test SSH over TCP
ssh -o ProxyCommand="openssl s_client -connect ssh.jeans-box.alphahorizon.io:443 -quiet" jean # Test SSH over TLS
```

[^note]: From GitHub, last checked 2022-02-19 ([https://github.com/traefik/traefik](https://github.com/traefik/traefik))
