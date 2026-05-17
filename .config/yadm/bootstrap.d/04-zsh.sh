#!/bin/bash
set -e

if ! command -v zsh &>/dev/null; then
    echo "安装 zsh..."
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm --needed zsh
    elif command -v apt &>/dev/null; then
        sudo apt update
        sudo apt install -y zsh
    fi
fi

chsh -s "$(command -v zsh)" || true
echo "zsh 已设为默认 shell。"
