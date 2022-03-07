# firewalld

firewalld is a firewall management tool for Linux operating systems[^note].

```shell
ssh jean@jeans-box.alphahorizon.io

sudo apt update
sudo apt install -y firewalld

sudo systemctl enable --now firewalld

sudo firewall-cmd --zone=public --add-interface=wlan0 --permanent
sudo firewall-cmd --zone=public --add-interface=eth0 --permanent

sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=mdns
sudo firewall-cmd --permanent --add-service=llmnr

sudo firewall-cmd --reload
```

[^note]: From Wikipedia, last checked 2022-02-19 ([https://en.wikipedia.org/wiki/Firewalld](https://en.wikipedia.org/wiki/Firewalld))
