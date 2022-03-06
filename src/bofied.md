# bofied

bofied is a network boot server[^note].

```shell
ssh jean@sdi-1.alphahorizon.io

sudo mkdir -p /var/lib/bofied

sudo podman run -d --restart=always --label "io.containers.autoupdate=image" --net host --cap-add NET_BIND_SERVICE -v /var/lib/bofied:/root/.local/share/bofied -e BOFIED_BACKEND_OIDCISSUER=https://dex.sdi-1.alphahorizon.io -e BOFIED_BACKEND_OIDCCLIENTID=bofied -e BOFIED_BACKEND_ADVERTISEDIP=143.198.37.173 --name bofied pojntfx/bofied-backend
sudo podman generate systemd --new bofied | sudo tee /lib/systemd/system/bofied.service

sudo systemctl daemon-reload
sudo systemctl enable --now bofied

sudo firewall-cmd --permanent --add-port=67/udp
sudo firewall-cmd --permanent --add-port=69/udp
sudo firewall-cmd --permanent --add-port=4011/udp
sudo firewall-cmd --reload
```

Visit [https://pojntfx.github.io/bofied/](https://pojntfx.github.io/bofied/) and login using the following credentials:

- Backend URL: `https://bofied.sdi-1.alphahorizon.io/`
- OIDC Issuer: `https://dex.sdi-1.alphahorizon.io`
- OIDC Client ID: `bofied`
- OIDC Redirect URL: `https://pojntfx.github.io/bofied/`

[^note]: From GitHub, last checked 2022-02-19 ([https://github.com/pojntfx/bofied](https://github.com/pojntfx/bofied))
