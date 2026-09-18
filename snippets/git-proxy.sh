# git over HTTPS through Stellar
git config --global http.proxy  http://127.0.0.1:8668
git config --global https.proxy http://127.0.0.1:8668
# undo:
# git config --global --unset http.proxy; git config --global --unset https.proxy
