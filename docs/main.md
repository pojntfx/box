---
author: [Felicitas Pojtinger]
date: "2021-12-11"
subject: "Box: Setup for my personal (pet) server."
keywords: [Rechnernetze, Protokoll, Versuch, HdM Stuttgart]
subtitle: "Setup for my personal (pet) server."
lang: "en"
---

# Box

## Introduction

### Contributing

**Found an error or have a suggestion?** Please open an issue on GitHub ([github.com/pojntfx/box](https://github.com/pojntfx/box)):

![QR-Code to the source code on GitHub](./static/qr.png){ width=150px }

### License

This document and included source code is Free Culture/Free Software.

![Badge of the AGPL-3.0 license](https://www.gnu.org/graphics/agplv3-155x51.png){ width=128px }

Box (c) 2021 Felicitas Pojtinger

SPDX-License-Identifier: AGPL-3.0

\newpage

## Debian

```shell
sudo umount /dev/mmcblk0{,p1,p0}
curl -L 'https://raspi.debian.net/tested/20210823_raspi_3_bullseye.img.xz' | xzcat >/tmp/debian.img
sudo dd if=/tmp/debian.img of=/dev/mmcblk0 bs=4M status=progress
sync

sudo mkdir -p /mnt/raspi-boot
sudo mount /dev/mmcblk0p1 /mnt/raspi-boot
{
    echo "root_pw=$(openssl rand -base64 12)"
    echo "root_authorized_key=$(cat ~/.ssh/id_rsa.pub)"
    echo "hostname=jeans-box"
} >>/mnt/raspi-boot/sysconf.txt
sudo umount /dev/mmcblk0{,p1,p0}
```

## IPv6

```shell
ssh root@jeans-box
tee /etc/sysctl.d/privacy.conf <<'EOT'
net.ipv6.conf.all.use_tempaddr=2
EOT
sysctl -p

tee /etc/network/interfaces.d/eth0 <<'EOT'
auto eth0
iface eth0 inet dhcp

iface eth0 inet6 static
    address 2001:7c7:2121:8d00::3
    autoconf 1
    accept_ra 2
EOT
systemctl restart networking

tee /etc/resolv.conf <<'EOT'
nameserver 2606:4700:4700::1111
nameserver 2606:4700:4700::1001
EOT
chattr +i /etc/resolv.conf
sed -i /etc/hosts -e 's/\tlocalhost/\tlocalhost jeans-box/g'
```

## DNS

```config
jeans-box     10800   IN      AAAA    2001:7c7:2121:8d00::3
*.jeans-box   10800   IN      AAAA    2001:7c7:2121:8d00::3
```

## SSH

```shell
ssh root@jeans-box.example.com
apt update
apt install -y sudo curl openssh-server locales
systemctl enable --now ssh

echo "LC_ALL=en_US.UTF-8" | tee -a /etc/environment
echo "en_US.UTF-8 UTF-8" | tee /etc/locale.gen
echo "LANG=en_US.UTF-8" | tee /etc/locale.conf
locale-gen en_US.UTF-8

adduser jean
su jean -c "mkdir -m 700 -p ~/.ssh && curl 'https://github.com/jean.keys' | tee -a ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
usermod -aG sudo jean

echo 'PermitRootLogin no' | tee /etc/ssh/ssh_config.d/no-root.conf

passwd -d root
passwd -l root
chsh -s /sbin/nologin
rm ~/.ssh/authorized_keys

systemctl restart ssh
```

## firewalld

```shell
ssh jean@jeans-box.example.com
sudo apt update
sudo apt install -y firewalld
sudo systemctl enable --now firewalld
sudo firewall-cmd --zone=public --add-interface=eth0 --permanent
sudo firewall-cmd --permanent --add-service=mdns
sudo firewall-cmd --permanent --add-service=llmnr
sudo firewall-cmd --reload
```

## APT

```shell
ssh jean@jeans-box.example.com
sudo apt update
sudo apt install -y unattended-upgrades

sudo tee /etc/apt/apt.conf.d/50unattended-upgrades <<'EOT'
Unattended-Upgrade::Origins-Pattern {
  "origin=*";
}
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOT
sudo systemctl enable --now unattended-upgrades
sudo unattended-upgrades --debug
```

## Traefik

```shell
ssh jean@jeans-box.example.com
sudo apt update
sudo apt install -y podman
echo 'unqualified-search-registries=["docker.io"]' | sudo tee /etc/containers/registries.conf.d/docker.conf
sudo systemctl enable --now podman-auto-update.timer

sudo mkdir -p /etc/traefik
sudo tee /etc/traefik/traefik.yaml<<'EOT'
entryPoints:
  web:
    address: ":80"

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
      rule: HostSNI(`ssh.jeans-box.example.com`)
      service: ssh
      tls:
        certResolver: letsencrypt
        domains:
          - main: ssh.jeans-box.example.com
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
      rule: Host(`traefik.jeans-box.example.com`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: traefik.jeans-box.example.com
      service: api@internal
      entryPoints:
        - websecure
      middlewares:
        - dashboard
    cockpit:
      rule: Host(`cockpit.jeans-box.example.com`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: cockpit.jeans-box.example.com
      service: cockpit
      entryPoints:
        - websecure
    gitea:
      rule: Host(`gitea.jeans-box.example.com`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: gitea.jeans-box.example.com
      service: gitea
      entryPoints:
        - websecure
    dex:
      rule: Host(`dex.jeans-box.example.com`)
      tls:
        certResolver: letsencrypt
        domains:
          - main: dex.jeans-box.example.com
      service: dex
      entryPoints:
        - websecure

  middlewares:
    dashboard:
      basicauth:
        users:
          - "jean:$apr1$dYdt8Zrl$TsEfzaedPGyjdrDk8EfRN." # htpasswd -nb htpasswd -nb jean asdf

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

  serversTransports:
    cockpit:
      insecureSkipVerify: true
EOT

sudo podman run -d --restart=always --net=host --label "io.containers.autoupdate=image" -v /var/lib/traefik/:/var/lib/traefik -v /etc/traefik/:/etc/traefik --name traefik traefik

sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --reload

curl -Lu jean:asdf https://traefik.jeans-box.example.com/ # Test the Traefik dashboard
ssh -p 8443 jean@jeans-box.example.com # Test SSH over TCP
ssh -o ProxyCommand="openssl s_client -connect ssh.jeans-box.example.com:443 -quiet" jean # Test SSH over TLS
```

## Cockpit

```shell
echo 'deb http://deb.debian.org/debian bullseye-backports main' | sudo tee /etc/apt/sources.list.d/backports.list
sudo apt update
sudo apt install -t bullseye-backports -y cockpit cockpit-podman cockpit-pcp

curl https://cockpit.jeans-box.example.com/ # Test Cockpit
```

## Gitea

```shell
sudo mkdir -p /var/lib/gitea
sudo podman run -d --restart=always --label "io.containers.autoupdate=image" --net slirp4netns:allow_host_loopback=true,enable_ipv6=true -p 3000:3000 -p 3022:22 -v /var/lib/gitea/:/data -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro -e 'USER_UID=1000' -e 'USER_GID=1000' --name gitea gitea/gitea
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --reload

curl https://gitea.jeans-box.example.com/ # Test Cockpit
```

Now visit [https://gitea.jeans-box.example.com/](https://gitea.jeans-box.example.com/) and run the Wizard; use the following values:

- SSH Server Domain: gitea.jeans-box.example.com
- SSH Server Port: 2222
- Gitea Base URL: https://gitea.jeans-box.example.com/
- Use your email SMTP server in `Email Settings`, enable `Email Notifications` and `Require Email Confirmation to Register`
- Under `Server and Third-Party Service Settings`, enable `Disable Self-Registration` (if you want to prevent others from using Gitea)
- Under `Administrator Account Settings`, create your admin account

Note that the installation might take a while (about 1 minute)

## Dex

First, setup Gitea by visiting [https://gitea.jeans-box.example.com/user/settings/applications](https://gitea.jeans-box.example.com/user/settings/applications) and adding a new OAuth2 application with Application Name `Dex` and Redirect URI `https://dex.jeans-box.example.com/callback`. Note the client ID and client secret; we'll need them in the following.

```shell
sudo mkdir -p /etc/dex
sudo mkdir -p /var/lib/dex
sudo touch /var/lib/dex/dex.db
sudo chown -R 1001:1001 /var/lib/dex/
sudo tee /etc/dex/config.yaml<<'EOT'
issuer: https://dex.jeans-box.example.com

storage:
    type: sqlite3
    config:
        file: /var/dex/dex.db

web:
    http: 0.0.0.0:5556
    allowedOrigins: ['*']

staticClients:
    - id: liwasc
      redirectURIs:
          - https://pojntfx.github.io/liwasc/
      name: "liwasc"
      public: true
    - id: bofied
      redirectURIs:
          - https://pojntfx.github.io/bofied/
      name: "bofied"
      public: true

connectors:
    - type: gitea
      id: gitea
      name: Gitea
      config:
          clientID: yourclientidfromgiteahere
          clientSecret: yourclientsecretfromgiteahere
          redirectURI: https://dex.jeans-box.example.com/callback
          baseURL: https://gitea.jeans-box.example.com
EOT
sudo podman run -d --restart=always --label "io.containers.autoupdate=image" --net slirp4netns:allow_host_loopback=true,enable_ipv6=true -p 5556:5556 -v /var/lib/dex:/var/dex -v /etc/dex:/etc/dex --name dex -it ghcr.io/dexidp/dex dex serve /etc/dex/config.yaml
```

You can test it out by visiting [https://pojntfx.github.io/liwasc/](https://pojntfx.github.io/liwasc/) and trying to log in using the following credentials:

- Backend URL: `ws://example.com` (we'll set this later; this is just to try out the login)
- OIDC Issuer: `https://dex.jeans-box.example.com`
- OIDC Client ID: `liwasc`
- OIDC Redirect URL: `https://pojntfx.github.io/liwasc/`

And authorization prompt from Gitea and Dex should show up, after which liwasc's home page should load (showing an error like `Failed to construct 'WebSocket': An insecure WebSocket connection may not be initiated from a page loaded over HTTPS.`).