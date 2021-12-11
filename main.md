-   [<span class="toc-section-number">0.1</span>
    Introduction](#introduction)
    -   [<span class="toc-section-number">0.1.1</span>
        Contributing](#contributing)
    -   [<span class="toc-section-number">0.1.2</span>
        License](#license)
-   [<span class="toc-section-number">0.2</span> Debian](#debian)
-   [<span class="toc-section-number">0.3</span> IPv6](#ipv6)
-   [<span class="toc-section-number">0.4</span> DNS](#dns)
-   [<span class="toc-section-number">0.5</span> SSH](#ssh)
-   [<span class="toc-section-number">0.6</span> firewalld](#firewalld)

Setup for my personal (pet) server.

Felicitas Pojtinger

2021-12-11

## Introduction

### Contributing

**Found an error or have a suggestion?** Please open an issue on GitHub
([github.com/pojntfx/box](https://github.com/pojntfx/box)):

<figure>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAXIAAAFyAQAAAADAX2ykAAACfElEQVR4nO2bTW7bMBBG31cJ0JICegAfRbpZ0ZuJR/EBCkjLABSmC4qy2iZxg9iCFAwXBk2/xQcMZjg/tIyPrPjtQzg477zzzjvvvPNv8VpWnXf5p6gamMpv/Y56nH8w35mZ2Qg2UJl6QH14kXoqMzOzP/ln63H+wfxUPLQbZxHbOTuxDYCkem89zj+Hly5mZtcaumt9n3+2Huc/x79iwrkGqiTCK7Xx0fQ7//4q9g0GTABTY4JZBnNtAFszH02/8//FR0lSC3Qj0I2VqZ8aU8+sTU59VP3Ov7Gy/249NCSMCSxeXsTfQfpo+p2/s3Lx05lZdl1CylkzhLUqCgtiw9H0O39n5ep2AGwIqcTnXA5Xtliacub2PRm/5Ffd2CJoDDCIKjG7G9u80z56nH8Grz5H4ITUzlIfEtIlZUYq7Y6j6nf+fX4Jw5N0a1LawCzi5da43E+P84/l1U8ShFSOpxr1VEZ3LYOHfkc9zj+Wt5+XBEw1xLbKkRoAqV3ceVc9zj+KX+ujtGTSZin3N3I6TVjPPH8+IU8Z/lX5ms27gWVXDF+s7/Y9MR8viZxVdaUmzjexWlC/ux7nP8+X/uTUiu5aI6gSsQfrxu+UwUNjXv+ekt/euqz9qyWTrmw58/v3rPzm/s1fB8CGYGaD95/Pz6/+a+WZ1eq6ayf69uH2PSd/ez9Jd2224TrXxP7+6qz8Zj54Gxgtu5BW//X66OR8eT+pHri9nyRKIrZeH30RfuO1TE1Osny+8IX47toYsZ2lH+O8vImOPl84K//v+0lm5fPYVklMdRLhV+GOpt/5O2v755PccF5bk5v61/Ork/Ly/3c777zzzjvv/O78b1Svnxk6HYUKAAAAAElFTkSuQmCC" width="150" alt="QR-Code to the source code on GitHub" /><figcaption aria-hidden="true">QR-Code to the source code on GitHub</figcaption>
</figure>

### License

This document and included source code is Free Culture/Free Software.

<figure>
<img src="data:image/png;base64,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" width="128" alt="Badge of the AGPL-3.0 license" /><figcaption aria-hidden="true">Badge of the AGPL-3.0 license</figcaption>
</figure>

Box (c) 2021 Felicitas Pojtinger

SPDX-License-Identifier: AGPL-3.0

## Debian

``` shell
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

``` shell
ssh root@jeans-box
cat >/etc/sysctl.d/privacy.conf <<'EOT'
net.ipv6.conf.all.use_tempaddr=2
EOT
sysctl -p

cat >/etc/network/interfaces.d/eth0 <<'EOT'
auto eth0
iface eth0 inet dhcp

iface eth0 inet6 static
    address 2001:7c7:2121:8d00::3
    autoconf 1
    accept_ra 2
EOT
systemctl restart networking

cat >/etc/resolv.conf <<'EOT'
nameserver 2606:4700:4700::1111
nameserver 2606:4700:4700::1001
EOT
sed -i /etc/hosts -e 's/\tlocalhost/\tlocalhost jeans-box/g'
```

## DNS

``` config
jeans-box     10800   IN      AAAA    2001:7c7:2121:8d00::3
*.jeans-box   10800   IN      AAAA    2001:7c7:2121:8d00::3
```

## SSH

``` shell
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

``` shell
ssh jean@jeans-box.example.com
sudo apt update
sudo apt install -y firewalld
sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-service=mdns
sudo firewall-cmd --permanent --add-service=llmnr
```
