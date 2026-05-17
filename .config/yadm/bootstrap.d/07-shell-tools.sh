#!/bin/bash
set -e

if [ -d "$HOME/shell-color-scripts" ]; then
    echo "shell-color-scripts 已安装，跳过。"
    exit 0
fi

echo "安装 shell-color-scripts..."
git clone https://gitlab.com/dwt1/shell-color-scripts.git "$HOME/shell-color-scripts"
cd "$HOME/shell-color-scripts"
sudo make install
cd ..
