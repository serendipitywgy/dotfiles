#!/bin/bash
set -e

if command -v nvim &>/dev/null; then
    echo "Neovim 已安装，跳过。"
    exit 0
fi

echo "安装 Neovim..."
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo mkdir -p /opt/nvim
sudo tar -C /opt/nvim --strip-components=1 -xzf nvim-linux-x86_64.tar.gz
echo 'export PATH="$PATH:/opt/nvim/bin"' >> "$HOME/.bashrc"
