# Gitea

Gitea is an open-source forge software package for hosting software development version control using Git as well as other collaborative features like bug tracking, wikis and code review[^note].

```shell
ssh jean@sdi-1.alphahorizon.io

sudo mkdir -p /var/lib/gitea

sudo podman run -d --restart=always --label "io.containers.autoupdate=image" --net slirp4netns:allow_host_loopback=true,enable_ipv6=true -p 3000:3000 -p 3022:22 -v /var/lib/gitea/:/data -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro -e 'USER_UID=1000' -e 'USER_GID=1000' --name gitea gitea/gitea
sudo podman generate systemd --new gitea | sudo tee /lib/systemd/system/gitea.service

sudo systemctl daemon-reload
sudo systemctl enable --now gitea

sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --reload

curl https://gitea.sdi-1.alphahorizon.io/ # Test Gitea
```

Visit [https://gitea.sdi-1.alphahorizon.io/](https://gitea.sdi-1.alphahorizon.io/) and run the Wizard; use the following values:

- Site Title: Jean's Gitea
- SSH Server Domain: gitea.sdi-1.alphahorizon.io
- SSH Server Port: 2222
- Gitea Base URL: https://gitea.sdi-1.alphahorizon.io/
- Use your email SMTP server in `Email Settings`, enable `Email Notifications` and `Require Email Confirmation to Register`
- Under `Server and Third-Party Service Settings`, enable `Disable Self-Registration` (if you want to prevent others from using Gitea)
- Under `Administrator Account Settings`, create your admin account

Note that the installation might take a while (about 1 minute)

[^note]: From Wikipedia, last checked 2022-02-19 ([https://en.wikipedia.org/wiki/Gitea](https://en.wikipedia.org/wiki/Gitea))
