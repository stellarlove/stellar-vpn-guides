---

# VPN on Linux: Ubuntu, Debian, Fedora and headless servers, step by step

**In short: Stellar ships a desktop client and a pure command-line helper for Linux.** The desktop build covers the mainstream distributions; the helper runs on anything with systemd. Most VPNs treat Linux as an afterthought, which is why many researchers and developers pick Stellar.

## Which build

| Situation | Build | Install |
| --- | --- | --- |
| Ubuntu / Debian / Linux Mint desktop | Desktop .deb | `dpkg -i` |
| Fedora / RHEL / Arch / other desktops | Desktop AppImage | make executable and run |
| Cloud server, WSL, Raspberry Pi, no desktop | Stellar Helper (CLI) | unpack the binary |

All packages are listed by platform on the [downloads page](https://stellar.dog/downloads).

## Ubuntu / Debian desktop

```bash
sudo dpkg -i stellar_*.deb
sudo apt-get install -f   # pull in dependencies
stellar                    # or launch from the app menu
```

The first connection asks for admin rights to install the helper service. After that the helper starts with the system and the client itself does not need root.

## Fedora / RHEL / other distributions

```bash
chmod +x Stellar-*.AppImage
./Stellar-*.AppImage
```

If FUSE is missing, install `fuse` or `libfuse2`, or run with `--appimage-extract`.

## Headless servers: Stellar Helper (CLI)

```bash
ARCH=amd64   # use arm64 on arm64 machines
curl -L -o stellar-helper.tar.gz "https://apps.stellar.international/stellar-helper-8.3.1-linux-${ARCH}.tar.gz"
tar xzf stellar-helper.tar.gz
sudo install -m 0755 stellar-helper /usr/local/bin/stellar-helper
stellar-helper login                                   # account email and password
stellar-helper lines                                   # list available lines
sudo stellar-helper connect --lineIndex 0 -c allowlist # smart split; -c global for everything
stellar-helper ctl state                               # status
```

Full command list and what `--computerMode` / `--proxyMode` mean in [helper commands](https://stellar.dog/en/docs/helper-commands); install details in [install CLI](https://stellar.dog/en/docs/install-cli).

## FAQ

**DNS does not change after connecting?** With systemd-resolved the helper takes over automatically; if you edited `/etc/resolv.conf` by hand, restore the default.

**Does Docker traffic go through?** With TUN mode on the host, container egress is routed too. To proxy a single container, set `HTTP_PROXY` to the local proxy port.

**Conflicts with another VPN or firewall?** Disable the other VPN's TUN device before connecting; default `ufw` policies are fine.

**WSL2?** Install the Windows desktop client; WSL2 traffic goes through the Windows network stack and is handled together.

Once installed, `pip`, `npm`, `git clone` and Claude Code all use a stable route. [Download Stellar for Linux](https://stellar.dog/downloads).
