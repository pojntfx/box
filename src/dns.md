# DNS

```shell
sudo umount /dev/sda{,0,1,2}

sudo mkdir -p /mnt/raspi-root
sudo mount /dev/sda2 /mnt/raspi-root

sudo tee /mnt/raspi-root/etc/resolv.conf<<'EOT'
nameserver 2606:4700:4700::1111
nameserver 2606:4700:4700::1001
nameserver 1.1.1.1
nameserver 1.0.0.1
EOT
sudo chattr +i /mnt/raspi-root/etc/resolv.conf

sudo sed -i /mnt/raspi-root/etc/hosts -e 's/\tlocalhost/\tlocalhost jeans-box/g'

sync
sudo umount /dev/sda{,0,1,2}
```

You can now also add the `AAAA` records for the device to your DNS zone (assuming that you've chosen a static IPv6 address):

> Adjust the IPv6 address to either the address you gave the wireless or wired network interface previously.

```dns
jeans-box   10800   IN  AAAA    2003:ef:1f01:7f00:76c9:d842:c369:8bf2
*.jeans-box 10800   IN  AAAA    2003:ef:1f01:7f00:76c9:d842:c369:8bf2
```
