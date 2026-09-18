---

# 终端代理配置：让 git、npm、pip、brew、curl 走 Stellar

**结论：Stellar 开启 TUN 模式后终端流量已经自动走线路，不需要配代理。** 只有在你关闭 TUN、或者只想让某几个工具走代理时，才需要下面的命令。本地 HTTP 代理端口默认 `8668`，SOCKS5 端口默认 `1080`，以客户端设置页或 `stellar-helper ctl state` 显示的为准。

## 一次性设置整个 shell

```bash
export HTTP_PROXY=http://127.0.0.1:8668
export HTTPS_PROXY=http://127.0.0.1:8668
export ALL_PROXY=socks5://127.0.0.1:1080
export NO_PROXY=localhost,127.0.0.1,::1,.cn,.local
```

写进 `~/.zshrc` 或 `~/.bashrc`。`NO_PROXY` 里放国内域名和内网地址，避免公司内网和 `.cn` 站点绕远路。

关掉代理：

```bash
unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
```

## 各工具单独设置

### git

```bash
git config --global http.proxy http://127.0.0.1:8668
git config --global https.proxy http://127.0.0.1:8668
# 取消
git config --global --unset http.proxy
git config --global --unset https.proxy
```

SSH 方式的 `git@github.com` 不走 HTTP 代理，可在 `~/.ssh/config` 里加：

```
Host github.com
  ProxyCommand nc -X connect -x 127.0.0.1:8668 %h %p
```

### npm / pnpm / yarn

```bash
npm config set proxy http://127.0.0.1:8668
npm config set https-proxy http://127.0.0.1:8668
```

pnpm 和 yarn 读同一套环境变量，设置了 `HTTPS_PROXY` 就够。

### pip

```bash
pip install --proxy http://127.0.0.1:8668 <package>
# 或写进 ~/.config/pip/pip.conf
[global]
proxy = http://127.0.0.1:8668
```

### Homebrew

Homebrew 用 curl 下载，`HTTPS_PROXY` 生效即可。`brew update` 走 git，按上面 git 的方式配置。

### curl / wget

```bash
curl -x http://127.0.0.1:8668 https://example.com
wget -e use_proxy=yes -e https_proxy=http://127.0.0.1:8668 https://example.com
```

### Docker

拉镜像走的是 Docker daemon，不读 shell 变量。macOS 的 Docker Desktop 在 Settings → Resources → Proxies 里填；Linux 在 `/etc/systemd/system/docker.service.d/proxy.conf` 里加 `Environment="HTTPS_PROXY=http://127.0.0.1:8668"` 后重启 docker。

## 验证

```bash
curl -s https://ifconfig.me      # 显示海外 IP 说明代理生效
curl -I https://api.anthropic.com
```

## 常见问题

**设置了变量还是超时？** 检查端口是否和客户端一致，客户端是否已连接。

**国内站点变慢？** 把对应域名加进 `NO_PROXY`，或者直接用 TUN 智能模式让客户端自动分流。

**公司 VPN 和 Stellar 一起用？** 先连公司 VPN，再开 Stellar 智能模式，内网地址放进 `NO_PROXY`。

大多数情况下开着 Stellar 的 TUN 智能模式就够了，这些配置留给需要精细控制的人。[下载 Stellar](https://stellar.dog/downloads)。
