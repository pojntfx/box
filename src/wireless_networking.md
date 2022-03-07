# Wireless Networking

## Debian

> Adjust the IPv6 address, SSID and PSK to your own values.

```shell
sudo umount /dev/sda{,0,1,2}

sudo mkdir -p /mnt/raspi-root
sudo mount /dev/sda2 /mnt/raspi-root

sudo tee /mnt/raspi-root/etc/network/interfaces.d/wlan0<<'EOT'
allow-hotplug wlan0

iface wlan0 inet dhcp

iface wlan0 inet6 static
    address 2003:ef:1f01:7f00:76c9:d842:c369:8bf2
    autoconf 1
    accept_ra 2

    wpa-ssid myssid
    wpa-psk mypsk
EOT

sync
sudo umount /dev/sda{,0,1,2}
```

## Raspbian

> Adjust the IPv6 address, SSID and PSK to your own values.

```shell
sudo umount /dev/sda{,0,1,2}

sudo mkdir -p /mnt/raspi-{boot,root}
sudo mount /dev/sda1 /mnt/raspi-boot
sudo mount /dev/sda2 /mnt/raspi-root

sudo tee /mnt/raspi-boot/wpa_supplicant.conf<<'EOT'
country=de
update_config=1
ctrl_interface=/var/run/wpa_supplicant

network={
    scan_ssid=1
    ssid="myssid"
    psk="mypsk"
}
EOT

sudo tee /mnt/raspi-root/etc/network/interfaces.d/wlan0<<'EOT'
allow-hotplug wlan0

iface wlan0 inet dhcp

iface wlan0 inet6 static
    address 2003:ef:1f01:7f00:76c9:d842:c369:8bf2
    autoconf 1
    accept_ra 2
EOT

sync
sudo umount /dev/sda{,0,1,2}
```
