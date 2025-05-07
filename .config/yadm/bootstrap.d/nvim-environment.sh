#!/bin/bash
set -e

echo "开始执行环境设置脚本..."

# 安装基础工具
echo "安装基础工具..."
sudo apt update
sudo apt install -y curl git unzip

# 安装 Rust
if ! command -v rustup &> /dev/null; then
    echo "安装 Rust..."
    curl --proto '=https' --tlsv1.2 -sSf "https://sh.rustup.rs" | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "Rust 已安装，跳过安装步骤。"
fi

# 安装 Neovide
if ! command -v neovide &> /dev/null; then
    echo "安装 Neovide..."
    ~/.cargo/bin/cargo install --git https://github.com/neovide/neovide
else
    echo "Neovide 已安装，跳过安装步骤。"
fi

# 安装 fzf, ripgrep, fd-find
echo "安装 fzf, ripgrep, fd-find..."
sudo apt install -y fzf ripgrep fd-find

# 根据显示服务器类型安装剪贴板工具
echo "检测显示服务器类型..."
if [ "$XDG_SESSION_TYPE" == "x11" ]; then
    echo "安装 xclip..."
    sudo apt install -y xclip
elif [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    echo "安装 wl-clipboard..."
    sudo apt install -y wl-clipboard
else
    echo "未知的显示服务器类型，无法安装剪贴板工具。"
fi

# 安装色彩显示工具
echo "安装 shell-color-scripts..."
if [ ! -d "$HOME/shell-color-scripts" ]; then
    git clone https://gitlab.com/dwt1/shell-color-scripts.git "$HOME/shell-color-scripts"
    cd "$HOME/shell-color-scripts"
    sudo make install
    cd ..
else
    echo "shell-color-scripts 已安装，跳过安装步骤。"
fi

# 下载并安装 JetBrains Mono 字体
echo "下载并安装 JetBrains Mono 字体..."
FONT_DIR="/usr/local/share/fonts/JetBrainsMono"
FONT_ZIP="JetBrainsMono.zip"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"

# 下载字体文件
if [ ! -f "$FONT_ZIP" ]; then
    echo "正在下载 JetBrains Mono 字体..."
    curl -LO "$FONT_URL"
else
    echo "JetBrains Mono 字体文件已存在，跳过下载步骤。"
fi

# 解压并安装字体
if [ -f "$FONT_ZIP" ]; then
    echo "解压并安装字体..."
    unzip -o "$FONT_ZIP" -d JetBrainsMono
    sudo mkdir -p "$FONT_DIR"
    sudo cp JetBrainsMono/*.ttf "$FONT_DIR/"
    sudo fc-cache -f -v
    echo "JetBrains Mono 字体已安装并更新字体缓存。"
else
    echo "未找到 JetBrains Mono 字体文件，跳过字体安装。"
fi

# 安装 Neovim
echo "安装 Neovim..."
if ! command -v nvim &> /dev/null; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim
    sudo mkdir -p /opt/nvim
    sudo tar -C /opt/nvim --strip-components=1 -xzf nvim-linux-x86_64.tar.gz
    echo 'export PATH="$PATH:/opt/nvim/bin"' >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
else
    echo "Neovim 已安装，跳过安装步骤。"
fi

echo "环境设置脚本执行完成！"
