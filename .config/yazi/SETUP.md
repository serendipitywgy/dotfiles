# Yazi 安装 / 同步到新电脑

> 把整个 `~/.config/yazi/` 拷到新机器后，按本文装好依赖与包即可。  
> 操作速查见同目录 [`KEYMAPS.md`](./KEYMAPS.md)。

---

## 1. 系统依赖

### 必装

| 包 | 用途 |
|----|------|
| `yazi` | 本体（需带 `ya` 命令，Arch 包名一般为 `yazi`） |
| `zoxide` | `z` 智能跳目录 |
| `fzf` | `Z` 模糊定位 |
| `fd` | 按文件名搜索 |
| `ripgrep`（`rg`） | 按内容搜索 |

Arch 示例：

```bash
sudo pacman -S yazi zoxide fzf fd ripgrep
```

### 建议装（预览 / 解压 / 剪贴板）

| 包 | 用途 |
|----|------|
| `ffmpeg` | 视频预览 / 缩略图 |
| `imagemagick` | 图片格式预览 |
| `poppler`（`pdftoppm`） | PDF 预览 |
| `jq` | JSON 预览 |
| `7zip` / `p7zip`（`7z`） | 压缩包预览与解压 |
| `wl-clipboard`（Wayland）或 `xclip`（X11） | 复制路径等到系统剪贴板 |
| `exiftool` | 图片 EXIF（配置里 `reveal` 用到） |
| `mediainfo` | 音视频信息（配置里 `play` 用到） |

Arch 示例：

```bash
sudo pacman -S ffmpeg imagemagick poppler jq 7zip wl-clipboard perl-image-exiftool mediainfo
```

确认：

```bash
yazi --version
ya --version
command -v zoxide fzf fd rg
```

---

## 2. 同步配置文件

需要同步的内容（本仓库 / 本目录）：

```text
~/.config/yazi/
├── yazi.toml          # 主配置（含 git fetcher）
├── keymap.toml        # 快捷键
├── theme.toml         # 主题引用
├── init.lua           # full-border / git / zoxide setup
├── package.toml       # 插件与 flavor 锁（ya pkg install 用）
├── SETUP.md           # 本文
└── KEYMAPS.md         # 操作速查
```

不必手拷：

- `flavors/`、`plugins/` → 用下面的 `ya pkg` 重新安装即可（也可整目录拷过去省事）

---

## 3. 安装 Yazi 插件与主题（必做）

配置已写在 `package.toml`。在 **任意目录** 执行：

```bash
# 方式 A：按锁文件一次装齐（推荐，新电脑首选）
ya pkg install

# 方式 B：没有 package.toml 时手动添加
ya pkg add yazi-rs/plugins:smart-enter
ya pkg add yazi-rs/plugins:full-border
ya pkg add yazi-rs/plugins:git
ya pkg add yazi-rs/plugins:smart-paste
ya pkg add yazi-rs/flavors:catppuccin-mocha
```

| 包 | 类型 | 作用 |
|----|------|------|
| `yazi-rs/plugins:smart-enter` | 插件 | `l` / `Enter` 进目录或打开文件 |
| `yazi-rs/plugins:smart-paste` | 插件 | `p` 智能粘贴 |
| `yazi-rs/plugins:full-border` | 插件 | 圆角全边框（`init.lua`） |
| `yazi-rs/plugins:git` | 插件 | 列表 Git 状态（`init.lua` + `yazi.toml` fetcher） |
| `yazi-rs/flavors:catppuccin-mocha` | 主题 | `theme.toml` 引用 |

内置、**不用** `ya pkg`：

| 能力 | 说明 |
|------|------|
| `zoxide` | 预设插件，依赖系统 `zoxide`；`init.lua` 里 `update_db = true` |
| `fzf` | 预设插件，依赖系统 `fzf` |

检查：

```bash
ya pkg list
ls ~/.config/yazi/plugins
ls ~/.config/yazi/flavors
```

升级：

```bash
ya pkg upgrade
```

---

## 4. Neovim 侧（若在工作机也用 yazi.nvim）

- 插件：`mikavilpas/yazi.nvim`（你 nvim 花名册里已有）
- 配置：`~/.config/nvim/lua/plugins/yazi.lua`（`open_for_directories`、`-` / `tt`）
- 系统仍须能跑通上面的 `yazi` + `ya pkg`；**Yazi 插件不装在 Mason / vim.pack 里**

---

## 5. 验证

```bash
yazi ~
# 应无 catppuccin + 全边框；仓库目录左侧/行内有 git 标记
# z → zoxide；l → smart-enter；p → smart-paste
```

若提示找不到 flavor，多半是第 3 步没跑，或 `theme.toml` 与 `flavors/` 不一致。
