# Linux

## Debian

> Debian, also known as Debian GNU/Linux, is a GNU/Linux distribution composed of free and open-source software, developed by the community-supported Debian Project, which was established by Ian Murdock on August 16, 1993[^note].

First, download and flash a prebuilt vanilla Debian image for your Raspberry Pi model:

```shell
# Raspberry Pi Zero (W)/1
curl -L 'https://raspi.debian.net/tested/20220121_raspi_1_bullseye.img.xz' | xzcat >/tmp/debian.img
# Raspberry Pi 2
curl -L 'https://raspi.debian.net/tested/20220121_raspi_2_bullseye.img.xz' | xzcat >/tmp/debian.img
# Raspberry Pi 3
curl -L 'https://raspi.debian.net/tested/20220121_raspi_3_bullseye.img.xz' | xzcat >/tmp/debian.img
# Raspberry Pi 4/400
curl -L 'https://raspi.debian.net/tested/20220121_raspi_4_bullseye.img.xz' | xzcat >/tmp/debian.img

sudo umount /dev/mmcblk0{,p0,p1,p2}

sudo dd if=/tmp/debian.img of=/dev/mmcblk0 bs=4M status=progress

sync
sudo umount /dev/mmcblk0{,p0,p1,p2}
```

For vanilla Debian, you can now mount the SD card and set the root password to a random string, add your `authorized_keys` and set the hostname like so:

> Adjust `/dev/mmcblk0` to the path of your SD card.

```shell
sudo umount /dev/mmcblk0{,p0,p1,p2}

sudo mkdir -p /mnt/raspi-boot
sudo mount /dev/mmcblk0p1 /mnt/raspi-boot

sudo tee /mnt/raspi-boot/sysconf.txt<<EOT
root_pw=$(openssl rand -base64 12)
root_authorized_key=$(cat ~/.ssh/id_rsa.pub)
hostname=jeans-box
EOT

sync
sudo umount /dev/mmcblk0{,p0,p1,p2}
```

## Raspbian

> Raspberry Pi OS (formerly Raspbian) is a Debian-based operating system for Raspberry Pi[^note2].

Alternatively, you may want to download and flash Raspbian instead of vanilla Debian by using the [Raspberry Pi Imager](https://flathub.org/apps/details/org.raspberrypi.rpi-imager). You can set the options mentioned above using the imager GUI; don't configure WLAN using it, as we'll use a static method instead.

[^note]: From Wikipedia, last checked 2022-02-19 ([https://en.wikipedia.org/wiki/Debian](https://en.wikipedia.org/wiki/Debian))

[^note2]: From Wikipedia, last checked 2022-03-07 ([https://en.wikipedia.org/wiki/Raspberry_Pi_OS](https://en.wikipedia.org/wiki/Raspberry_Pi_OS))
