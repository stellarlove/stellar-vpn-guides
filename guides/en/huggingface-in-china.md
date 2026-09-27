# Downloading Hugging Face models from China

**In short: `huggingface.co` resolves but the CDN that actually serves the weights (`cdn-lfs.huggingface.co`) is what stalls**, so a download starts at a few MB/s and then drops to zero somewhere in the middle of a 4 GB shard.

## The symptoms

```
OSError: We couldn't connect to 'https://huggingface.co' to load this file

requests.exceptions.ReadTimeout: HTTPSConnectionPool(host='cdn-lfs.huggingface.co',
port=443): Read timed out.
```

Or a `snapshot_download` that reaches 60% and never moves again.

## Option 1 — the mirror endpoint

For public models this is the simplest fix:

```bash
export HF_ENDPOINT=https://hf-mirror.com
```

It works with `huggingface_hub`, `transformers`, `datasets` and the `hf` CLI. Put it in `~/.zshrc` if you use it often.

Limits worth knowing: gated models (Llama, some Mistral releases) need your real token against the real host, private repos are not mirrored, and the mirror lags upstream by hours to days.

## Option 2 — proxy

Needed for gated or private repos, and whenever you want the same setup to work for `pip`, `git` and the Hub at once:

```bash
export HTTPS_PROXY=http://127.0.0.1:8668
export HTTP_PROXY=http://127.0.0.1:8668
export NO_PROXY=localhost,127.0.0.1,*.cn
```

`huggingface_hub` honours these automatically — it uses `requests` underneath.

### Large files

Resumable, parallel downloads help a lot on a long-haul link:

```bash
pip install hf_transfer
export HF_HUB_ENABLE_HF_TRANSFER=1
```

If a download still dies midway, `snapshot_download` resumes from the cache, so just run it again:

```python
from huggingface_hub import snapshot_download
snapshot_download("Qwen/Qwen2.5-7B-Instruct", resume_download=True)
```

### git clone of a model repo

Model repos use Git LFS, and LFS ignores `http.proxy`:

```bash
git config --global http.proxy http://127.0.0.1:8668
git config --global https.proxy http://127.0.0.1:8668
git config --global lfs.transfer.maxretries 10
```

### Ollama

Ollama pulls from its own registry, not the Hub, and runs as a service:

```bash
# macOS
launchctl setenv HTTPS_PROXY http://127.0.0.1:8668
# Linux systemd — same pattern as the Docker daemon
sudo systemctl edit ollama
```

## With Stellar

`huggingface.co`, `cdn-lfs.huggingface.co`, `cdn-lfs-us-1.hf.co` and `registry.ollama.ai` are in Stellar's routed list, so with the client running the standard `HTTPS_PROXY=http://127.0.0.1:8668` is all you need — including for gated repos where the mirror cannot help.

Related: [terminal proxy setup](https://stellar.dog/docs/terminal-proxy) · [Claude Code / Codex / Gemini CLI in China](https://stellar.dog/docs/claude-code-in-china) · [docker pull times out](https://stellar.dog/docs/docker-pull-in-china)
