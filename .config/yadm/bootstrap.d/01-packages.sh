#!/bin/bash
set -e

echo "安装基础工具..."

if command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm --needed curl git unzip fzf ripgrep fd

    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        sudo pacman -S --noconfirm --needed wl-clipboard
    elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
        sudo pacman -S --noconfirm --needed xclip
    fi

elif command -v apt &>/dev/null; then
    sudo apt update
    sudo apt install -y curl git unzip fzf ripgrep fd-find

    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        sudo apt install -y wl-clipboard
    elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
        sudo apt install -y xclip
    fi

else
    echo "未知包管理器，请手动安装以下工具："
    echo "curl, git, unzip, fzf, ripgrep, fd"
fi
