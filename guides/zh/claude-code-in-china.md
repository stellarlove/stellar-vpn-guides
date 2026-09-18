---

# Claude Code、Codex、Gemini CLI 在国内连不上怎么办

**结论：这几个工具都直接连 Anthropic、OpenAI、Google 的 API，在国内要么超时，要么被判定为不支持的地区。** 解决办法是让终端流量走一条稳定的海外线路，并且确认代理环境变量设置正确。Stellar 对这几个工具的域名做了专门的路由优化，装好后通常不需要额外配置。

## 常见报错对应的原因

| 报错 | 原因 |
| --- | --- |
| `fetch failed` / `ETIMEDOUT` / `ECONNRESET` | API 域名在国内直连不通 |
| `Request not allowed` / `unsupported_country` | 出口 IP 被判定为不支持的地区 |
| 登录页面打不开、OAuth 回调卡住 | 浏览器和终端走的不是同一条线路 |
| `429` 频繁 | 共享出口 IP 太多人用，换一条线路即可 |

## 方法一：装 Stellar 客户端（推荐）

1. 从 [下载页](https://stellar.dog/downloads) 安装 macOS、Windows 或 Linux 客户端并登录。
2. 连接后保持智能模式。Claude、OpenAI、Google 的 API 域名已经在内置规则里，终端和浏览器会一起走海外线路。
3. 重新运行 `claude`、`codex` 或 `gemini`。如果之前设置过 `HTTPS_PROXY` 之类的变量指向别的工具，先 `unset` 掉，避免冲突。

Linux 服务器或没有图形界面的机器，用命令行版 Stellar Helper，见 [安装 CLI](https://stellar.dog/zh/docs/install-cli)。

## 方法二：只让终端走代理

如果你想让浏览器直连、只给终端加代理，Stellar 的本地 HTTP 代理端口默认是 `8668`，在 shell 里设置：

```bash
export HTTPS_PROXY=http://127.0.0.1:8668
export HTTP_PROXY=http://127.0.0.1:8668
export NO_PROXY=localhost,127.0.0.1,.cn
```

端口以客户端设置页或 `stellar-helper ctl state` 显示的为准。写进 `~/.zshrc` 或 `~/.bashrc` 后重新打开终端。

## 各工具的注意点

- **Claude Code**：首次 `claude` 登录会打开浏览器完成 OAuth，浏览器和终端要走同一条线路。登录后的 token 存在本地，之后只需要终端能连上 API。
- **Codex CLI**：同样依赖 OpenAI API 域名，注意不要同时设置 `OPENAI_BASE_URL` 指向失效的中转。
- **Gemini CLI**：Google 对地区判断更严格，遇到 `location not supported` 时切换到美国或日本线路。

## 还是不行时

1. 切换一条线路，再试一次。
2. 临时切到全局模式，排除规则遗漏。
3. `curl -I https://api.anthropic.com` 看能否返回 HTTP 头；能返回说明网络通了，问题在工具配置。
4. 参考 [故障排查](https://stellar.dog/zh/docs/troubleshooting)，或联系客服并附上报错原文。

装好 Stellar 之后，Claude Code、Codex、Gemini 在国内和在海外一样用。[下载 Stellar](https://stellar.dog/downloads)。
