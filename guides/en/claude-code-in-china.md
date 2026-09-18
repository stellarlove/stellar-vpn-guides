---

# Claude Code, Codex and Gemini CLI not connecting from China? Here is the fix

**In short: these tools talk directly to the Anthropic, OpenAI and Google APIs, which either time out or reject the region from inside China.** The fix is a stable overseas route for your terminal plus correct proxy variables. Stellar ships routing rules for exactly these domains, so after installing it usually needs no extra setup.

## What the errors mean

| Error | Cause |
| --- | --- |
| `fetch failed` / `ETIMEDOUT` / `ECONNRESET` | The API domain is unreachable directly |
| `Request not allowed` / `unsupported_country` | Your exit IP is in an unsupported region |
| Login page never loads, OAuth callback hangs | Browser and terminal are on different routes |
| Frequent `429` | A crowded shared exit IP; switch line |

## Option 1: install the Stellar client (recommended)

1. Install the macOS, Windows or Linux client from the [downloads page](https://stellar.dog/downloads) and log in.
2. Connect and stay in smart mode. The Anthropic, OpenAI and Google API domains are already in the built-in rules, so terminal and browser share the overseas route.
3. Run `claude`, `codex` or `gemini` again. If you previously exported `HTTPS_PROXY` pointing at another tool, `unset` it first.

For headless Linux boxes use the command-line Stellar Helper; see [install CLI](https://stellar.dog/en/docs/install-cli).

## Option 2: proxy only the terminal

To keep the browser direct and proxy just the shell, Stellar exposes a local HTTP proxy on port `8668` by default:

```bash
export HTTPS_PROXY=http://127.0.0.1:8668
export HTTP_PROXY=http://127.0.0.1:8668
export NO_PROXY=localhost,127.0.0.1,.cn
```

Confirm the port in the client settings or with `stellar-helper ctl state`. Put the lines in `~/.zshrc` or `~/.bashrc` and open a new terminal.

## Tool-specific notes

- **Claude Code**: the first `claude` run opens a browser for OAuth; browser and terminal must be on the same route. The token is stored locally afterwards, so only API reachability matters.
- **Codex CLI**: same OpenAI API domains; make sure `OPENAI_BASE_URL` is not pointing at a dead relay.
- **Gemini CLI**: Google checks region more strictly; on `location not supported` switch to a US or Japan line.

## Still failing

1. Switch to another line and retry.
2. Temporarily use global mode to rule out a missing rule.
3. `curl -I https://api.anthropic.com` — if headers come back, the network is fine and the problem is tool config.
4. See [troubleshooting](https://stellar.dog/en/docs/troubleshooting) or contact support with the exact error text.

With Stellar installed, Claude Code, Codex and Gemini work from China the way they do abroad. [Download Stellar](https://stellar.dog/downloads).
