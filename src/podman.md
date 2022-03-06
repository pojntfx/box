# Podman

Podman is a daemonless container engine for developing, managing, and running OCI Containers on your Linux System[^note].

> Run on both `sdi-1` and `sdi-2`; adjust the values accordingly.

```shell
ssh jean@sdi-1.alphahorizon.io

echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_11/ /' | sudo tee /etc/apt/sources.list.d/libcontainers.list
curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_11/Release.key" | sudo apt-key add -
sudo apt update
sudo apt upgrade -y # Prevent conflicts with eventual prior Podman install from Debian repos
sudo apt install -t Debian_11 -y podman
echo 'unqualified-search-registries=["docker.io"]' | sudo tee /etc/containers/registries.conf.d/docker.conf
sudo systemctl unmask podman-auto-update.service
sudo systemctl unmask podman-auto-update.timer
sudo systemctl enable --now podman-auto-update.timer
sudo systemctl enable --now podman-restart
```

[^note]: From the Podman website, last checked 2022-02-19 ([https://podman.io/](https://podman.io/))
