#!/bin/bash
set -e

if command -v kitty &>/dev/null; then
    echo "kitty 已安装，跳过。"
    exit 0
fi

if command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm --needed kitty
elif command -v apt &>/dev/null; then
    echo "下载并安装 kitty（官方脚本）..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    mkdir -p ~/.local/bin
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
fi
