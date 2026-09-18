---

# Terminal proxy setup: route git, npm, pip, brew and curl through Stellar

**In short: with Stellar's TUN mode on, terminal traffic is already routed and you need none of this.** These commands are for when TUN is off or you want only certain tools proxied. The local HTTP proxy port defaults to `8668` and SOCKS5 to `1080`; confirm in the client settings or with `stellar-helper ctl state`.

## Set the whole shell at once

```bash
export HTTP_PROXY=http://127.0.0.1:8668
export HTTPS_PROXY=http://127.0.0.1:8668
export ALL_PROXY=socks5://127.0.0.1:1080
export NO_PROXY=localhost,127.0.0.1,::1,.cn,.local
```

Add them to `~/.zshrc` or `~/.bashrc`. Put domestic domains and internal addresses in `NO_PROXY` so office networks and `.cn` sites stay direct.

To turn it off:

```bash
unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
```

## Per tool

### git

```bash
git config --global http.proxy http://127.0.0.1:8668
git config --global https.proxy http://127.0.0.1:8668
# undo
git config --global --unset http.proxy
git config --global --unset https.proxy
```

SSH remotes (`git@github.com`) ignore HTTP proxies; add to `~/.ssh/config`:

```
Host github.com
  ProxyCommand nc -X connect -x 127.0.0.1:8668 %h %p
```

### npm / pnpm / yarn

```bash
npm config set proxy http://127.0.0.1:8668
npm config set https-proxy http://127.0.0.1:8668
```

pnpm and yarn read the same environment variables, so `HTTPS_PROXY` is enough.

### pip

```bash
pip install --proxy http://127.0.0.1:8668 <package>
# or in ~/.config/pip/pip.conf
[global]
proxy = http://127.0.0.1:8668
```

### Homebrew

Homebrew downloads with curl, so `HTTPS_PROXY` applies. `brew update` uses git; configure git as above.

### curl / wget

```bash
curl -x http://127.0.0.1:8668 https://example.com
wget -e use_proxy=yes -e https_proxy=http://127.0.0.1:8668 https://example.com
```

### Docker

Image pulls go through the Docker daemon, which ignores shell variables. On macOS set it in Docker Desktop → Settings → Resources → Proxies; on Linux add `Environment="HTTPS_PROXY=http://127.0.0.1:8668"` to `/etc/systemd/system/docker.service.d/proxy.conf` and restart docker.

## Verify

```bash
curl -s https://ifconfig.me      # an overseas IP means the proxy works
curl -I https://api.anthropic.com
```

## FAQ

**Variables set but still timing out?** Check the port matches the client and that the client is connected.

**Domestic sites got slow?** Add them to `NO_PROXY`, or just use TUN smart mode and let the client split traffic.

**Corporate VPN together with Stellar?** Connect the corporate VPN first, then Stellar in smart mode, with internal ranges in `NO_PROXY`.

Most people just leave Stellar's TUN smart mode on; this page is for fine-grained control. [Download Stellar](https://stellar.dog/downloads).
