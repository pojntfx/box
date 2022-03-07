# Wired Networking

> Adjust the IPv6 address to your own value.

```shell
sudo umount /dev/sda{,0,1,2}

sudo mkdir -p /mnt/raspi-root
sudo mount /dev/sda2 /mnt/raspi-root

sudo tee /mnt/raspi-root/etc/network/interfaces.d/eth0<<'EOT'
auto eth0

iface eth0 inet dhcp

iface eth0 inet6 static
    address 2003:ef:1f01:7f00:76c9:d842:c369:8bf3
    autoconf 1
    accept_ra 2
EOT

sync
sudo umount /dev/sda{,0,1,2}
```
