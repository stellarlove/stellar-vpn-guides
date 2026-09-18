# Route the current shell through Stellar's local proxy (defaults: HTTP 8668, SOCKS5 1080).
# source this file, or paste into ~/.zshrc / ~/.bashrc
export HTTP_PROXY=http://127.0.0.1:8668
export HTTPS_PROXY=http://127.0.0.1:8668
export ALL_PROXY=socks5://127.0.0.1:1080
export NO_PROXY=localhost,127.0.0.1,::1,.cn,.local
alias proxy-off='unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY'
