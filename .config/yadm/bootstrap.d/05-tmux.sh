#!/bin/bash
set -e

echo "安装 tmux..."
if command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm --needed tmux
elif command -v apt &>/dev/null; then
    sudo apt update
    sudo apt install -y tmux
fi

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "安装 TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "安装 tmux 插件..."
~/.tmux/plugins/tpm/bin/install_plugins
