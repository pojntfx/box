# SSH

The Secure Shell Protocol (SSH) is a cryptographic network protocol for operating network services securely over an unsecured network[^note].

Access the server:

```shell
# Debian
ssh root@jeans-box.alphahorizon.io
# Raspbian
ssh -tt pi@jeans-box.alphahorizon.io sudo su -l
```

If your Raspberry Pi doesn't have a static IPv6 address, you can connect to it by using `jeans-box` instead of `jeans-box.alphahorizon.io`, e.g. by using `ssh root@jeans-box`, which uses mDNS to resolve the Raspberry Pi's address.

Create the user:

```shell
echo "LC_ALL=en_US.UTF-8" | tee -a /etc/environment
echo "en_US.UTF-8 UTF-8" | tee /etc/locale.gen
echo "LANG=en_US.UTF-8" | tee /etc/locale.conf
locale-gen en_US.UTF-8

adduser jean
su jean -c "mkdir -m 700 -p ~/.ssh && curl 'https://github.com/jean.keys' | tee -a ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
usermod -aG sudo jean

# Only on Raspbian: Delete the default `pi` user
sh -c 'killall -u pi && deluser --remove-home pi'
```

Setup SSH:

```shell
ssh jean@jeans-box.alphahorizon.io

sudo apt update
sudo apt install -y sudo curl openssh-server locales
sudo systemctl enable --now ssh

echo 'PermitRootLogin no' | sudo tee /etc/ssh/ssh_config.d/no-root.conf

sudo passwd -d root
sudo passwd -l root
sudo chsh -s /sbin/nologin
sudo rm -f /root/.ssh/authorized_keys

sudo systemctl restart ssh
```

[^note]: From Wikipedia, last checked 2022-02-19 ([https://en.wikipedia.org/wiki/Secure_Shell](https://en.wikipedia.org/wiki/Secure_Shell))
