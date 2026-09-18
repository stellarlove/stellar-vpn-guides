---

# Linux 上安装 VPN：Ubuntu、Debian、Fedora 和无界面服务器的完整步骤

**结论：Stellar 对 Linux 有桌面版和纯命令行版两种，桌面版覆盖主流发行版，命令行版可以跑在任何有 systemd 的机器上。** 大多数 VPN 只把 Linux 当二等公民，这也是很多科研和开发用户选 Stellar 的原因。

## 选哪个版本

| 场景 | 版本 | 安装方式 |
| --- | --- | --- |
| Ubuntu / Debian / Linux Mint 桌面 | 桌面版 .deb | `dpkg -i` |
| Fedora / RHEL / Arch / 其他桌面 | 桌面版 AppImage | 加执行权限直接运行 |
| 云服务器、WSL、树莓派、无桌面机器 | Stellar Helper（CLI） | 解压二进制 |

所有安装包都在 [下载页](https://stellar.dog/downloads) 按平台列出。

## Ubuntu / Debian 桌面版

```bash
sudo dpkg -i stellar_*.deb
sudo apt-get install -f   # 补齐依赖
stellar                    # 或从应用菜单启动
```

首次连接会请求管理员权限来安装 helper 服务，输入密码即可。之后 helper 随系统启动，客户端本身不需要 root。

## Fedora / RHEL / 其他发行版

```bash
chmod +x Stellar-*.AppImage
./Stellar-*.AppImage
```

如果提示缺少 FUSE，装 `fuse` 或 `libfuse2` 包，或者用 `--appimage-extract` 解压后运行。

## 无界面服务器：Stellar Helper（CLI）

```bash
ARCH=amd64   # arm64 机器改成 arm64
curl -L -o stellar-helper.tar.gz "https://apps.stellar.international/stellar-helper-8.3.1-linux-${ARCH}.tar.gz"
tar xzf stellar-helper.tar.gz
sudo install -m 0755 stellar-helper /usr/local/bin/stellar-helper
stellar-helper login                                   # 输入账号密码
stellar-helper lines                                   # 列出可用线路
sudo stellar-helper connect --lineIndex 0 -c allowlist # 智能分流；全局用 -c global
stellar-helper ctl state                               # 查看状态
```

完整命令和 `--computerMode`、`--proxyMode` 的含义见 [Helper 命令](https://stellar.dog/zh/docs/helper-commands)，安装细节见 [安装 CLI](https://stellar.dog/zh/docs/install-cli)。

## 常见问题

**连接后 DNS 不生效？** 系统用 systemd-resolved 时，helper 会自动接管；手动改过 `/etc/resolv.conf` 的机器请恢复默认。

**Docker 容器里的流量走不走？** 宿主机开 TUN 模式后，容器的出站流量默认也会经过 Stellar。只想让某个容器走，用 HTTP 代理端口配置 `HTTP_PROXY`。

**和已有的 VPN 或防火墙冲突？** 关掉其它 VPN 的 TUN 设备再连；`ufw` 默认策略不影响。

**WSL2 里怎么用？** 在 Windows 上装桌面版即可，WSL2 的流量走 Windows 网络栈，会一起被处理。

装完之后，`pip`、`npm`、`git clone` 和 Claude Code 都会走稳定线路。[下载 Linux 版 Stellar](https://stellar.dog/downloads)。
