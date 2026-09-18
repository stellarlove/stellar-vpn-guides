#!/usr/bin/env bash
# Install the standalone Stellar Helper CLI on Linux (amd64/arm64) or macOS.
# Usage: curl -fsSL https://raw.githubusercontent.com/stellarlove/stellar-vpn-guides/main/scripts/install-stellar-helper.sh | bash
set -euo pipefail
VERSION="${STELLAR_HELPER_VERSION:-8.3.1}"
BASE="https://apps.stellar.international"
OS="$(uname -s)"
case "$OS" in
  Linux)
    case "$(uname -m)" in
      x86_64|amd64) ARCH=amd64 ;;
      aarch64|arm64) ARCH=arm64 ;;
      *) echo "unsupported arch: $(uname -m)"; exit 1 ;;
    esac
    FILE="stellar-helper-${VERSION}-linux-${ARCH}.tar.gz" ;;
  Darwin)
    FILE="stellar-helper-${VERSION}-darwin-universal.tar.gz" ;;
  *) echo "unsupported OS: $OS"; exit 1 ;;
esac
TMP="$(mktemp -d)"
echo "Downloading ${BASE}/${FILE}"
curl -fL -o "${TMP}/helper.tar.gz" "${BASE}/${FILE}"
tar xzf "${TMP}/helper.tar.gz" -C "${TMP}"
sudo install -m 0755 "${TMP}/stellar-helper" /usr/local/bin/stellar-helper
[ "$OS" = Darwin ] && sudo xattr -dr com.apple.quarantine /usr/local/bin/stellar-helper || true
rm -rf "${TMP}"
echo "Installed: $(stellar-helper version 2>/dev/null | head -1)"
echo "Next: stellar-helper login && stellar-helper lines && sudo stellar-helper connect --lineIndex 0 -c allowlist"
