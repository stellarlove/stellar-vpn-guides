# docker pull times out in China

**In short: `docker pull` fails from inside China because Docker Hub's registry and its CDN are both unreliable there.** A domestic mirror fixes the common images; anything else — private registries, `ghcr.io`, `gcr.io`, `quay.io`, or a `docker build` that fetches from GitHub — needs a proxy, and Docker does not pick up your shell's proxy variables by itself.

## The errors you will see

```
Error response from daemon: Get "https://registry-1.docker.io/v2/":
net/http: TLS handshake timeout

error pulling image configuration: download failed after attempts=6:
dial tcp 3.94.224.37:443: i/o timeout
```

Both mean the same thing: the daemon reached the address and the connection was cut, not that the image is missing.

## Step 1 — decide whether you need a mirror or a proxy

| What you pull | What fixes it |
| --- | --- |
| `nginx`, `redis`, `python`, `node` … official Docker Hub images | a registry mirror is enough and is faster |
| `ghcr.io/...`, `gcr.io/...`, `quay.io/...`, `registry.k8s.io/...` | proxy — mirrors do not carry these |
| your own private registry abroad | proxy |
| `docker build` whose Dockerfile runs `git clone`, `pip install`, `npm i` | proxy, and it has to reach the build container |

Using a mirror where you actually need a proxy is the most common wasted hour.

## Step 2a — registry mirror (Docker Hub images only)

Docker Desktop → Settings → Docker Engine, then add:

```json
{
  "registry-mirrors": ["https://docker.m.daocloud.io"]
}
```

On a Linux server the same block goes in `/etc/docker/daemon.json`, then:

```bash
sudo systemctl restart docker
```

Verify it took effect:

```bash
docker info | grep -A2 "Registry Mirrors"
```

## Step 2b — proxy for the daemon

**The daemon is a separate process. Exporting `HTTPS_PROXY` in your shell does nothing for `docker pull`.**

Docker Desktop (macOS / Windows) → Settings → Resources → Proxies → Manual proxy configuration:

```
HTTP  http://127.0.0.1:8668
HTTPS http://127.0.0.1:8668
Bypass  localhost,127.0.0.1,*.cn,*.aliyuncs.com
```

Linux with systemd:

```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/proxy.conf >/dev/null <<'EOF'
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:8668"
Environment="HTTPS_PROXY=http://127.0.0.1:8668"
Environment="NO_PROXY=localhost,127.0.0.1,*.cn"
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## Step 3 — proxy inside `docker build`

Build containers get their own network namespace, so `127.0.0.1` there is the container, not your machine. Pass the host address explicitly:

```bash
docker build \
  --build-arg HTTP_PROXY=http://host.docker.internal:8668 \
  --build-arg HTTPS_PROXY=http://host.docker.internal:8668 \
  -t myimage .
```

On Linux `host.docker.internal` is not defined by default; use the bridge address (usually `172.17.0.1`) or add `--add-host=host.docker.internal:host-gateway`.

## With Stellar

Stellar listens on `127.0.0.1:8668` and already routes `registry-1.docker.io`, `ghcr.io`, `gcr.io`, `quay.io`, `pkg-containers.githubusercontent.com` and `production.cloudflare.docker.com` through its international lines, so once the daemon points at the proxy the pull just works — no mirror needed, including for private and non-Docker-Hub registries.

Related: [terminal proxy setup](https://stellar.dog/docs/terminal-proxy) · [what needs a VPN in China](https://stellar.dog/docs/what-needs-vpn-in-china) · [Linux install](https://stellar.dog/docs/linux-vpn)
