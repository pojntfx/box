# Traefik

Traefik (pronounced traffic) is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy[^note].

## Manager (`sdi-1`)

```shell
ssh jean@sdi-1.alphahorizon.io

sudo mkdir -p /etc/traefik
sudo tee /etc/traefik/traefik.yaml<<'EOT'
entryPoints:
  dnsTCP:
    address: ":53"

  dnsUDP:
    address: ":53/udp"

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

  metrics:
    address: "localhost:8082"

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

metrics:
  prometheus:
    entryPoint: metrics
EOT

sudo tee /etc/traefik/services.yaml<<'EOT'
udp:
  routers:
    dns:
      entryPoints:
        - dnsUDP
      service: dns
  services:
    dns:
      loadBalancer:
        servers:
          - address: localhost:54

tcp:
  routers:
    dns:
      entryPoints:
        - dnsTCP
      rule: HostSNI(`*`)
      service: dns
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
      rule: HostSNI(`ssh.sdi-1.alphahorizon.io`)
      service: ssh
      tls:
        certResolver: letsencrypt
        domains:
          - main: ssh.sdi-1.alphahorizon.io
    ldap:
      entryPoints:
        - websecure
      rule: HostSNI(`ldap.sdi-1.alphahorizon.io`)
      service: ldap
      tls:
        certResolver: letsencrypt
        domains:
          - main: ldap.sdi-1.alphahorizon.io
  services:
    dns:
      loadBalancer:
        servers:
          - address: localhost:54
    ssh:
      loadBalancer:
        servers:
          - address: localhost:22
    giteaSSH:
      loadBalancer:
        servers:
          - address: localhost:3022
    ldap:
      loadBalancer:
        servers:
          - address: localhost:389

http:
  routers:
    dashboard:
      rule: Host(`traefik.sdi-1.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: traefik.sdi-1.alphahorizon.io
      service: api@internal
      entryPoints:
        - websecure
      middlewares:
        - dashboard
    cockpit:
      rule: Host(`cockpit.sdi-1.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: cockpit.sdi-1.alphahorizon.io
      service: cockpit
      entryPoints:
        - websecure
    gitea:
      rule: Host(`gitea.sdi-1.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: gitea.sdi-1.alphahorizon.io
      service: gitea
      entryPoints:
        - websecure
    dex:
      rule: Host(`dex.sdi-1.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: dex.sdi-1.alphahorizon.io
      service: dex
      entryPoints:
        - websecure
    liwasc:
      rule: Host(`liwasc.sdi-1.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: liwasc.sdi-1.alphahorizon.io
      service: liwasc
      entryPoints:
        - websecure
    bofied:
      rule: Host(`bofied.sdi-1.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: bofied.sdi-1.alphahorizon.io
      service: bofied
      entryPoints:
        - websecure
    apache:
      rule: Host(`apache.sdi-1.alphahorizon.io`) || HostRegexp(`{subdomain:[a-z]+}.apache.sdi-1.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: apache.sdi-1.alphahorizon.io
          - main: marx.apache.sdi-1.alphahorizon.io
          - main: kropotkin.apache.sdi-1.alphahorizon.io
          - main: secure.apache.sdi-1.alphahorizon.io
      service: apache
      entryPoints:
        - websecure
    phpmyadmin:
      rule: Host(`phpmyadmin.sdi-1.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: phpmyadmin.sdi-1.alphahorizon.io
      service: apache
      entryPoints:
        - websecure
    ldapAccountManager:
      rule: Host(`ldap-account-manager.sdi-1.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: ldap-account-manager.sdi-1.alphahorizon.io
      service: apache
      entryPoints:
        - websecure
    nextcloud:
      rule: Host(`nextcloud.sdi-1.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: nextcloud.sdi-1.alphahorizon.io
      service: apache
      entryPoints:
        - websecure
    grafana:
      rule: Host(`grafana.sdi-1.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: grafana.sdi-1.alphahorizon.io
      service: grafana
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
    apache:
      loadBalancer:
        servers:
          - url: http://localhost:8080
    grafana:
      loadBalancer:
        servers:
          - url: http://localhost:3001

  serversTransports:
    cockpit:
      insecureSkipVerify: true
EOT

sudo mkdir -p /var/lib/traefik

sudo podman run -d --restart=always --label "io.containers.autoupdate=image" --net=host -v /var/lib/traefik/:/var/lib/traefik -v /etc/traefik/:/etc/traefik --name traefik traefik
sudo podman generate systemd --new traefik | sudo tee /lib/systemd/system/traefik.service

sudo systemctl daemon-reload
sudo systemctl enable --now traefik

sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --reload

curl -Lu jean:asdf https://traefik.sdi-1.alphahorizon.io/ # Test the Traefik dashboard
ssh -p 8443 jean@sdi-1.alphahorizon.io # Test SSH over TCP
ssh -o ProxyCommand="openssl s_client -connect ssh.sdi-1.alphahorizon.io:443 -quiet" jean # Test SSH over TLS
```

## Worker (`sdi-2`)

```shell
ssh jean@sdi-2.alphahorizon.io

sudo mkdir -p /etc/traefik
sudo tee /etc/traefik/traefik.yaml<<'EOT'
entryPoints:
  dnsTCP:
    address: ":53"

  dnsUDP:
    address: ":53/udp"

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
udp:
  routers:
    dns:
      entryPoints:
        - dnsUDP
      service: dns
  services:
    dns:
      loadBalancer:
        servers:
          - address: localhost:54

tcp:
  routers:
    dns:
      entryPoints:
        - dnsTCP
      rule: HostSNI(`*`)
      service: dns
    ssh:
      entryPoints:
        - websecurealt
      rule: HostSNI(`*`)
      service: ssh
    sshOverTLS:
      entryPoints:
        - websecure
      rule: HostSNI(`ssh.sdi-2.alphahorizon.io`)
      service: ssh
      tls:
        certResolver: letsencrypt
        domains:
          - main: ssh.sdi-2.alphahorizon.io
  services:
    dns:
      loadBalancer:
        servers:
          - address: localhost:54
    ssh:
      loadBalancer:
        servers:
          - address: localhost:22

http:
  routers:
    dashboard:
      rule: Host(`traefik.sdi-2.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: traefik.sdi-2.alphahorizon.io
      service: api@internal
      entryPoints:
        - websecure
      middlewares:
        - dashboard
    cockpit:
      rule: Host(`cockpit.sdi-2.alphahorizon.io`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: cockpit.sdi-2.alphahorizon.io
      service: cockpit
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

  serversTransports:
    cockpit:
      insecureSkipVerify: true
EOT

sudo mkdir -p /var/lib/traefik

sudo podman run -d --restart=always --label "io.containers.autoupdate=image" --net=host -v /var/lib/traefik/:/var/lib/traefik -v /etc/traefik/:/etc/traefik --name traefik traefik
sudo podman generate systemd --new traefik | sudo tee /lib/systemd/system/traefik.service

sudo systemctl daemon-reload
sudo systemctl enable --now traefik

sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --reload

curl -Lu jean:asdf https://traefik.sdi-2.alphahorizon.io/ # Test the Traefik dashboard
ssh -p 8443 jean@sdi-2.alphahorizon.io # Test SSH over TCP
ssh -o ProxyCommand="openssl s_client -connect ssh.sdi-2.alphahorizon.io:443 -quiet" jean # Test SSH over TLS
```

[^note]: From GitHub, last checked 2022-02-19 ([https://github.com/traefik/traefik](https://github.com/traefik/traefik))
