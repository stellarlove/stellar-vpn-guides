# docker pull 超时怎么办

**一句话：国内拉不动 Docker Hub，是因为它的 registry 和 CDN 在国内都不稳。**常用官方镜像配个国内镜像源就能解决；但私有仓库、`ghcr.io`、`gcr.io`、`quay.io`，以及 `docker build` 过程中要去 GitHub 拉东西的情况，只能走代理——而且 **Docker 不会自动读你终端里的代理变量**。

## 你会看到的报错

```
Error response from daemon: Get "https://registry-1.docker.io/v2/":
net/http: TLS handshake timeout

error pulling image configuration: download failed after attempts=6:
dial tcp 3.94.224.37:443: i/o timeout
```

两个都是同一回事：连上了但被掐断，不是镜像不存在。

## 第一步 — 先判断该用镜像源还是代理

| 你要拉的东西 | 该用什么 |
| --- | --- |
| `nginx`、`redis`、`python`、`node` 这类 Docker Hub 官方镜像 | 镜像源就够，而且更快 |
| `ghcr.io/...`、`gcr.io/...`、`quay.io/...`、`registry.k8s.io/...` | 代理——镜像源不收录这些 |
| 自己在海外的私有仓库 | 代理 |
| Dockerfile 里有 `git clone`、`pip install`、`npm i` 的 `docker build` | 代理，而且要送进构建容器里 |

该用代理的时候去配镜像源，是最常见的白折腾一小时。

## 第二步 A — 配镜像源（只对 Docker Hub 有效）

Docker Desktop → Settings → Docker Engine，加上：

```json
{
  "registry-mirrors": ["https://docker.m.daocloud.io"]
}
```

Linux 服务器上同样的内容写进 `/etc/docker/daemon.json`，然后：

```bash
sudo systemctl restart docker
```

确认生效：

```bash
docker info | grep -A2 "Registry Mirrors"
```

## 第二步 B — 给 daemon 配代理

**daemon 是独立进程，你在终端里 `export HTTPS_PROXY` 对 `docker pull` 一点用都没有。**

Docker Desktop（macOS / Windows）→ Settings → Resources → Proxies → 手动配置：

```
HTTP  http://127.0.0.1:8668
HTTPS http://127.0.0.1:8668
绕过  localhost,127.0.0.1,*.cn,*.aliyuncs.com
```

Linux（systemd）：

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

## 第三步 — 让 `docker build` 里面也能走代理

构建容器有自己的网络命名空间，里面的 `127.0.0.1` 指的是容器自己，不是你的机器。要显式传宿主机地址：

```bash
docker build \
  --build-arg HTTP_PROXY=http://host.docker.internal:8668 \
  --build-arg HTTPS_PROXY=http://host.docker.internal:8668 \
  -t myimage .
```

Linux 上默认没有 `host.docker.internal`，用网桥地址（一般是 `172.17.0.1`），或者加 `--add-host=host.docker.internal:host-gateway`。

## 用 Stellar 的话

Stellar 在 `127.0.0.1:8668` 上监听，并且已经把 `registry-1.docker.io`、`ghcr.io`、`gcr.io`、`quay.io`、`pkg-containers.githubusercontent.com`、`production.cloudflare.docker.com` 都走国际线路，所以 daemon 指过去之后直接就能拉——包括私有仓库和非 Docker Hub 的仓库，不需要再配镜像源。

相关：[终端代理配置](https://stellar.dog/docs/terminal-proxy) · [回国后哪些要走代理](https://stellar.dog/docs/what-needs-vpn-in-china) · [Linux 安装](https://stellar.dog/docs/linux-vpn)
