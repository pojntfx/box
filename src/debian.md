# Debian

Debian, also known as Debian GNU/Linux, is a GNU/Linux distribution composed of free and open-source software, developed by the community-supported Debian Project, which was established by Ian Murdock on August 16, 1993[^note].

> Adjust `/dev/mmcblk0` to the path of your SD card.

```shell
# For the Raspberry Pi 3
curl -L 'https://raspi.debian.net/tested/20220121_raspi_3_bullseye.img.xz' | xzcat >/tmp/debian.img
# For the Raspberry Pi Zero W
curl -L 'https://raspi.debian.net/tested/20220121_raspi_1_bullseye.img.xz' | xzcat >/tmp/debian.img

sudo umount /dev/mmcblk0{,p1,p0}

sudo dd if=/tmp/debian.img of=/dev/mmcblk0 bs=4M status=progress
sync

sudo mkdir -p /mnt/raspi-boot
sudo mount /dev/mmcblk0p1 /mnt/raspi-boot

sudo tee /mnt/raspi-boot/sysconf.txt<<EOT
root_pw=$(openssl rand -base64 12)
root_authorized_key=$(cat ~/.ssh/id_rsa.pub)
hostname=jeans-box
EOT

sudo umount /dev/mmcblk0{,p0,p1,p2}
```

[^note]: From Wikipedia, last checked 2022-02-19 ([https://en.wikipedia.org/wiki/Debian](https://en.wikipedia.org/wiki/Debian))
