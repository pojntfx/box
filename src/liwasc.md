# liwasc

liwasc is a high-performance network and port scanner[^note].

```shell
ssh jean@sdi-1.alphahorizon.io

sudo mkdir -p /var/lib/liwasc

sudo podman run -d --restart=always --label "io.containers.autoupdate=image" --net host --cap-add NET_RAW --ulimit nofile=16384:16384 -v /var/lib/liwasc:/root/.local/share/liwasc -e LIWASC_BACKEND_OIDCISSUER=https://dex.sdi-1.alphahorizon.io -e LIWASC_BACKEND_OIDCCLIENTID=liwasc -e LIWASC_BACKEND_DEVICENAME=eth0 -e LIWASC_BACKEND_PERIODICSCANCRONEXPRESSION='0 0 * * *' --name liwasc pojntfx/liwasc-backend
sudo podman generate systemd --new liwasc | sudo tee /lib/systemd/system/liwasc.service

sudo systemctl daemon-reload
sudo systemctl enable --now liwasc
```

Visit [https://pojntfx.github.io/liwasc/](https://pojntfx.github.io/liwasc/) as we did before and use `wss://liwasc.sdi-1.alphahorizon.io/` as the backend URL (note the trailing slash!).

[^note]: From GitHub, last checked 2022-02-19 ([https://github.com/pojntfx/liwasc](https://github.com/pojntfx/liwasc))
