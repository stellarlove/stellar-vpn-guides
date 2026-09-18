# Stellar VPN guides · 使用指南

Practical, copy-pasteable guides for people who need Google, Instagram, YouTube, ChatGPT and Claude to keep working from China, and for developers running Claude Code / Codex / Gemini CLI there. Bilingual (中文 / English). Product site: **https://stellar.dog**.

给准备回国的留学生、海外华人，以及需要在国内使用 Claude Code / Codex / Gemini 的开发者的实用指南，中英双语。

## Guides · 指南

| 中文 | English |
| --- | --- |
| [回国前的网络准备清单](guides/zh/returning-to-china.md) | [Keep Google, Instagram and ChatGPT working after moving back to China](guides/en/returning-to-china.md) |
| [Claude Code、Codex、Gemini CLI 在国内连不上怎么办](guides/zh/claude-code-in-china.md) | [Claude Code, Codex and Gemini CLI from China](guides/en/claude-code-in-china.md) |
| [Linux 上安装 VPN（Ubuntu / Debian / Fedora / 服务器）](guides/zh/linux-vpn.md) | [VPN on Linux: Ubuntu, Debian, Fedora and headless servers](guides/en/linux-vpn.md) |
| [终端代理配置：git、npm、pip、brew、curl](guides/zh/terminal-proxy.md) | [Terminal proxy setup: git, npm, pip, brew, curl](guides/en/terminal-proxy.md) |
| [回国后哪些网站和 App 需要 VPN](guides/zh/what-needs-vpn-in-china.md) | [Which sites and apps need a VPN in China](guides/en/what-needs-vpn-in-china.md) |

## Scripts · 脚本

- `scripts/install-stellar-helper.sh` — install the standalone CLI helper on Linux (amd64 / arm64) or macOS:

  ```bash
  curl -fsSL https://raw.githubusercontent.com/stellarlove/stellar-vpn-guides/main/scripts/install-stellar-helper.sh | bash
  stellar-helper login
  stellar-helper lines
  sudo stellar-helper connect --lineIndex 0 -c allowlist
  ```

- `snippets/shell-proxy.sh`, `snippets/git-proxy.sh`, `snippets/ssh-config-github` — proxy snippets for the terminal (HTTP `8668`, SOCKS5 `1080` by default).

## Platforms · 平台

Windows · macOS · iOS · Android · Linux (deb / AppImage / CLI). One account, every platform. Downloads: https://stellar.dog/downloads · Docs: https://stellar.dog/manual · FAQ: https://stellar.dog/faq

Issues and PRs welcome — corrections to any command are especially appreciated.
