# 国内下载 Hugging Face 模型

**一句话：`huggingface.co` 能解析，真正卡住的是发权重文件的 CDN（`cdn-lfs.huggingface.co`）**——所以下载往往先跑几 MB/s，然后在 4GB 分片下到一半时归零。

## 常见报错

```
OSError: We couldn't connect to 'https://huggingface.co' to load this file

requests.exceptions.ReadTimeout: HTTPSConnectionPool(host='cdn-lfs.huggingface.co',
port=443): Read timed out.
```

或者 `snapshot_download` 跑到 60% 就再也不动了。

## 方案一 — 镜像站

公开模型用这个最省事：

```bash
export HF_ENDPOINT=https://hf-mirror.com
```

`huggingface_hub`、`transformers`、`datasets` 和 `hf` 命令行都认这个变量。常用的话写进 `~/.zshrc`。

要知道它的边界：gated 模型（Llama、部分 Mistral）需要拿你的 token 去真站点验证；私有仓库不会被镜像；镜像同步会比上游慢几小时到几天。

## 方案二 — 走代理

gated / 私有仓库必须用，而且能让 `pip`、`git`、Hub 一套设置全搞定：

```bash
export HTTPS_PROXY=http://127.0.0.1:8668
export HTTP_PROXY=http://127.0.0.1:8668
export NO_PROXY=localhost,127.0.0.1,*.cn
```

`huggingface_hub` 底层用 `requests`，会自动读这些变量。

### 大文件

跨境长链路上，断点续传 + 并行分片差别很大：

```bash
pip install hf_transfer
export HF_HUB_ENABLE_HF_TRANSFER=1
```

中途断了也不用重来，`snapshot_download` 会从缓存续传，重跑即可：

```python
from huggingface_hub import snapshot_download
snapshot_download("Qwen/Qwen2.5-7B-Instruct", resume_download=True)
```

### git clone 模型仓库

模型仓库用 Git LFS，而 **LFS 不读 `http.proxy`**：

```bash
git config --global http.proxy http://127.0.0.1:8668
git config --global https.proxy http://127.0.0.1:8668
git config --global lfs.transfer.maxretries 10
```

### Ollama

Ollama 拉的是自己的 registry，不是 Hub，而且以服务方式运行：

```bash
# macOS
launchctl setenv HTTPS_PROXY http://127.0.0.1:8668
# Linux systemd —— 和 Docker daemon 一个套路
sudo systemctl edit ollama
```

## 用 Stellar 的话

`huggingface.co`、`cdn-lfs.huggingface.co`、`cdn-lfs-us-1.hf.co`、`registry.ollama.ai` 都在 Stellar 的路由列表里，客户端开着的时候，标准的 `HTTPS_PROXY=http://127.0.0.1:8668` 就够了——包括镜像站帮不了你的 gated 仓库。

相关：[终端代理配置](https://stellar.dog/docs/terminal-proxy) · [Claude Code / Codex / Gemini CLI 在国内连不上](https://stellar.dog/docs/claude-code-in-china) · [docker pull 超时](https://stellar.dog/docs/docker-pull-in-china)
