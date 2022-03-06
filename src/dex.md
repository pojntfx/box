# Dex

Dex is an identity service that uses OpenID Connect to drive authentication for other apps[^note].

First, setup Gitea by visiting [https://gitea.sdi-1.alphahorizon.io/user/settings/applications](https://gitea.sdi-1.alphahorizon.io/user/settings/applications) and adding a new OAuth2 application with Application Name `Dex` and Redirect URI `https://dex.sdi-1.alphahorizon.io/callback`. Note the client ID and client secret; we'll need them in the following.

```shell
ssh jean@sdi-1.alphahorizon.io

sudo mkdir -p /etc/dex /var/lib/dex

sudo touch /var/lib/dex/dex.db
sudo chown -R 1001:1001 /var/lib/dex/

sudo tee /etc/dex/config.yaml<<'EOT'
issuer: https://dex.sdi-1.alphahorizon.io

storage:
    type: sqlite3
    config:
        file: /var/dex/dex.db

web:
    http: 0.0.0.0:5556
    allowedOrigins: ['*']

staticClients:
    - id: liwasc
      redirectURIs:
          - https://pojntfx.github.io/liwasc/
      name: "liwasc"
      public: true
    - id: bofied
      redirectURIs:
          - https://pojntfx.github.io/bofied/
      name: "bofied"
      public: true

connectors:
    - type: gitea
      id: gitea
      name: Gitea
      config:
          clientID: yourclientidfromgiteahere
          clientSecret: yourclientsecretfromgiteahere
          redirectURI: https://dex.sdi-1.alphahorizon.io/callback
          baseURL: https://gitea.sdi-1.alphahorizon.io
EOT

sudo podman run -d --restart=always --label "io.containers.autoupdate=image" --net slirp4netns:allow_host_loopback=true,enable_ipv6=true -p 5556:5556 -v /var/lib/dex:/var/dex -v /etc/dex:/etc/dex --name dex ghcr.io/dexidp/dex dex serve /etc/dex/config.yaml
sudo podman generate systemd --new dex | sudo tee /lib/systemd/system/dex.service

sudo systemctl daemon-reload
sudo systemctl enable --now dex
```

You can test it out by visiting [https://pojntfx.github.io/liwasc/](https://pojntfx.github.io/liwasc/) and trying to log in using the following credentials:

- Backend URL: `ws://example.com/` (we'll set this later; this is just to try out the login)
- OIDC Issuer: `https://dex.sdi-1.alphahorizon.io`
- OIDC Client ID: `liwasc`
- OIDC Redirect URL: `https://pojntfx.github.io/liwasc/`

And authorization prompt from Gitea and Dex should show up, after which liwasc's home page should load (showing an error like `Failed to construct 'WebSocket': An insecure WebSocket connection may not be initiated from a page loaded over HTTPS.`).

[^note]: From the Dex website, last checked 2022-02-19 ([https://dexidp.io/](https://dexidp.io/))
