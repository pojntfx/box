# Cockpit

Cockpit is a web-based graphical interface for servers[^note].

> Run on both `sdi-1` and `sdi-2`; adjust the values accordingly.

```shell
ssh jean@sdi-1.alphahorizon.io

echo 'deb http://deb.debian.org/debian bullseye-backports main' | sudo tee /etc/apt/sources.list.d/backports.list
sudo apt update
sudo apt install -t bullseye-backports -y cockpit cockpit-podman cockpit-pcp

curl https://cockpit.sdi-1.alphahorizon.io/ # Test Cockpit
```

[^note]: From the Cockpit website, last checked 2022-02-19 ([https://cockpit-project.org/](https://cockpit-project.org/))
