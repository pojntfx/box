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
apt install -y sudo curl openssh-server
systemctl enable --now ssh

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
sudo firewall-cmd --permanent --add-service=mdns
sudo firewall-cmd --permanent --add-service=llmnr
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