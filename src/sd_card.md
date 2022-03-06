# SD Card

Debian, also known as Debian GNU/Linux, is a GNU/Linux distribution composed of free and open-source software, developed by the community-supported Debian Project, which was established by Ian Murdock on August 16, 1993[^note].

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
```

Alternatively, you may want to download and flash Raspbian instead of vanilla Debian by using the [Raspberry Pi Imager](https://flathub.org/apps/details/org.raspberrypi.rpi-imager).

For vanilla Debian, you can now mount the SD card and set the root password, add your `authorized_keys` and set the hostname like so:

```shell

```

<!--Don't forget to add the empty `ssh` file to enable the SSH server -->

If you chose Raspbian, you can do the same like so:

```shell

```

[^note]: From Wikipedia, last checked 2022-02-19 ([https://en.wikipedia.org/wiki/Debian](https://en.wikipedia.org/wiki/Debian))
