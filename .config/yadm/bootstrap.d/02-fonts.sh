#!/bin/bash
set -e

if fc-list | grep -qi "JetBrainsMono\|JetBrains.*Mono" &>/dev/null; then
    echo "JetBrains Mono 字体已安装，跳过。"
    exit 0
fi

echo "下载并安装 JetBrains Mono 字体..."
FONT_DIR="/usr/local/share/fonts/JetBrainsMono"
FONT_ZIP="JetBrainsMono.zip"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"

if [ ! -f "$FONT_ZIP" ]; then
    curl -LO "$FONT_URL"
fi

if [ -f "$FONT_ZIP" ]; then
    unzip -o "$FONT_ZIP" -d JetBrainsMono
    sudo mkdir -p "$FONT_DIR"
    sudo cp JetBrainsMono/*.ttf "$FONT_DIR/"
    sudo fc-cache -f -v
fi
