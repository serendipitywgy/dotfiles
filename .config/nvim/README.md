# Neovim 配置文档

> 基于 Neovim 0.12 内置包管理器 `vim.pack` 的现代化 Neovim 配置

## 目录结构

```
~/.config/nvim/
├── init.lua                  # 入口文件
├── nvim-pack-lock.json       # 插件版本锁文件
└── lua/
    ├── pack/
    │   ├── init.lua          # PackUtils 引擎 + 管理命令
    │   └── plugins.lua       # 插件花名册（集中管理下载地址）
    ├── config/
    │   ├── options.lua       # vim 选项配置
    │   ├── keymaps.lua       # 全局快捷键
    │   ├── autocmds.lua      # 自动命令
    │   ├── lsp.lua           # LSP 配置（Mason + lspconfig）
    │   ├── debugging.lua     # DAP 调试器配置
    │   ├── utils.lua         # 通用工具函数
    │   ├── icons.lua         # 图标定义
    │   └── heirline/
    │       ├── statusline.lua
    │       └── components.lua
    └── plugins/              # 各插件的独立配置文件
        ├── theme.lua
        ├── snacks.lua
        ├── blink.lua
        ├── treesitter.lua
        ├── heirline.lua
        ├── bufferline.lua
        ├── oil.lua
        ├── yazi.lua
        ├── git.lua
        ├── debug.lua
        ├── mini.lua
        ├── noice.lua
        ├── which-key.lua
        ├── flash.lua
        ├── autopairs.lua
        ├── cmake.lua
        ├── render-markdown.lua
        ├── auto-session.lua
        ├── vim-tmux-navigator.lua
        ├── windsurf.lua
        ├── inc-rename.lua
        └── static-scroll.lua
```

---

## 插件管理机制

### 核心：`vim.pack`（Neovim 0.12 内置）

本配置**不依赖任何第三方插件管理器**（如 lazy.nvim / packer），完全使用 Neovim 0.12 原生的 `vim.pack` API。

#### 基本流程

```
init.lua
  └─ require("pack")
       ├─ 初始化 PackUtils 引擎
       ├─ require("pack.plugins")   ← 集中注册所有插件 spec，调用 vim.pack.add()
       ├─ 自动扫描 lua/plugins/*.lua 并逐一 require（加载各插件配置）
       └─ require("config.lsp")
```

#### `pack/plugins.lua` — 插件花名册

所有插件的下载地址统一在此文件声明为 `specs` 列表，再通过 `vim.pack.add(specs)` 一次性下载/同步。
支持字符串（仅 URL）或 table（含 `src`、`name`、`version` 等字段）两种格式：

```lua
local specs = {
    { src = "https://github.com/folke/snacks.nvim" },
    { src = "https://github.com/saghen/blink.cmp", version = "v1.7.0" },
    "https://github.com/christoomey/vim-tmux-navigator",
}
vim.pack.add(specs)
```

#### 管理命令

| 命令 | 说明 |
|------|------|
| `:PackUpdate [name...]` | 更新全部或指定插件（支持 Tab 补全插件名） |
| `:PackStatus [name...]` | 检查插件状态（offline 模式，不下载） |

---

### `PackUtils` 引擎

`PackUtils` 是封装在 `pack/init.lua` 中的全局工具对象，为插件配置提供统一的加载、构建与防崩保护。

#### 核心 API

| 函数 | 说明 |
|------|------|
| `PackUtils.get_name(spec)` | 从 URL 或 table 解析插件名 |
| `PackUtils.get_root(name)` | 获取插件在磁盘上的根目录 |
| `PackUtils.sync(active, disabled)` | 自动删除孤儿插件；注册禁用名单 |
| `PackUtils.load(P, config_fn)` | 全方位防崩加载：`packadd` + 依赖挂载 + `require` + `setup` |
| `PackUtils.run_build(name, cmd)` | 执行编译/安装命令（支持 shell 命令和 `:VimCmd` 两种形式） |
| `PackUtils.setup_listener(name, cmd)` | 注册 `PackChanged` 监听，安装/更新后自动触发构建 |
| `PackUtils.check_health(name, cmd)` | 启动时检查 `.build_done` 标记，缺失则触发构建 |

#### `PackUtils.load` 参数格式

```lua
PackUtils.load({
    name = "yazi.nvim",        -- 插件名（或 GitHub URL，自动解析）
    module = "yazi",           -- require 的模块名
    deps = { "plenary.nvim" }, -- 依赖列表（可选）
    build_cmd = "make",        -- 构建命令（可选）
}, function(plugin)
    plugin.setup({ ... })
end)
```

#### 禁用插件

在 `pack/plugins.lua` 的 `disabled` 列表中添加插件 spec，该插件将：
- 不被加载（`PackUtils.load` 提前退出）
- 不被删除（保留在磁盘，避免误删）
- 新安装时不被下载

---

## 配置设计逻辑

### 分层结构

```
init.lua          ← 极简入口，仅做 leader 设置 + 4 个 require
  pack/           ← 插件管理层（下载 + 引擎 + 扫描加载）
  config/         ← 核心配置层（选项 / 快捷键 / 自动命令 / LSP）
  plugins/        ← 插件配置层（每个插件一个独立文件）
```

### 懒加载策略

配置中大量使用 `autocmd` 实现懒加载，而不依赖 lazy.nvim 的 event 系统：

| 触发时机 | 适用插件 |
|----------|----------|
| `InsertEnter` | blink.cmp、nvim-autopairs |
| `BufReadPost` | gitsigns、mini.diff |
| `BufReadPre` / `BufNewFile` | heirline、bufferline |
| `LspAttach` | inc-rename |
| `FileType python/cpp/c` | DAP 调试器 |
| `FileType markdown` | render-markdown、image.nvim |
| 按键触发 | yazi（`tt`）、flash（`ss`） |

### 自动扫描插件配置

`pack/init.lua` 在初始化完成后自动扫描 `lua/plugins/` 目录，所有 `.lua` 文件均被 `pcall(require, ...)` 安全加载，**新增插件只需在此目录添加文件即可，无需修改 `init.lua`**。

### 防崩保护

- 所有插件加载均用 `pcall` 包裹
- `PackUtils.load` 在 `require` 失败时优雅退出并打印 `vim.notify` 警告
- `PackUtils.is_initialized` 表防止重复初始化

---

## 编辑器选项（`config/options.lua`）

| 选项 | 值 | 说明 |
|------|----|------|
| `mapleader` | `<Space>` | Leader 键 |
| `clipboard` | `unnamedplus` | 系统剪贴板共享 |
| `number` / `relativenumber` | `true` | 相对行号 |
| `wrap` | `true` | 启用自动换行 |
| `colorcolumn` | `150` | 第 150 列参考线 |
| `cursorline` | `true` | 高亮当前行 |
| `expandtab` / `shiftwidth` / `tabstop` | `4` | 4 空格缩进 |
| `undofile` | `true` | 持久化撤销历史 |
| `foldmethod` | `expr` | Treesitter 表达式折叠 |
| `foldexpr` | `vim.treesitter.foldexpr()` | Treesitter 折叠表达式 |

折叠文本使用自定义函数 `custom_foldtext()`，带 Treesitter 语法高亮和折叠行数提示。

---

## 快捷键

> `<leader>` = `<Space>`

### 基础导航

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `j` / `k` | n/x | 视觉行移动（换行时按视觉行而非实际行） |
| `kj` / `KJ` | i | 退出插入模式（等同 `<Esc>`） |
| `<Esc>` | n | 清除搜索高亮 |

### 窗口 / Buffer

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<C-h/j/k/l>` | n | 切换窗口（tmux 环境下透传给 vim-tmux-navigator） |
| `<C-Up/Down/Left/Right>` | n | 调整窗口大小 |
| `<leader>-` | n | 横向分屏 |
| `<leader>\|` | n | 纵向分屏 |
| `<leader>wd` | n | 关闭当前窗口 |
| `<S-h>` / `<S-l>` | n | 切换上/下一个 buffer |
| `<leader>bd` | n | 删除 buffer（Snacks） |
| `<leader>bD` | n | 删除 buffer 和窗口 |
| `<leader>bp` | n | 视觉选择 buffer（BufferLine） |
| `<leader>bc` | n | 视觉关闭 buffer（BufferLine） |

### 文件 / 保存

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>w` | n | 保存当前 buffer |
| `<leader>q` | n | 退出当前 buffer |
| `<leader>qq` | n | 保存全部并退出 |
| `<leader>e` | n | 打开 Oil 文件管理器 |
| `tt` | n/v | 打开 Yazi 文件管理器 |

### Snacks Picker（模糊搜索）

| 快捷键 | 说明 |
|--------|------|
| `<leader><space>` | Smart Find Files |
| `<leader>,` | Buffers |
| `<leader>/` | Grep |
| `<leader>:` | Command History |
| `<leader>ff` | Find Files |
| `<leader>fb` | Buffers |
| `<leader>fc` | 查找配置文件 |
| `<leader>fg` | Find Git Files |
| `<leader>fp` | Projects |
| `<leader>fr` | Recent Files |
| `<leader>sg` | Grep |
| `<leader>sw` | Grep 当前单词/选中内容 |
| `<leader>sb` | Buffer Lines |
| `<leader>sB` | Grep 所有打开 buffer |
| `<leader>sd` | Diagnostics |
| `<leader>sD` | Buffer Diagnostics |
| `<leader>sh` | Help Pages |
| `<leader>sk` | Keymaps |
| `<leader>ss` | LSP Symbols |
| `<leader>sS` | LSP Workspace Symbols |
| `<leader>su` | Undo History |
| `<leader>sj` | Jumps |
| `<leader>sm` | Marks |
| `<leader>sq` | Quickfix List |
| `<leader>sR` | Resume 上次搜索 |
| `<leader>uC` | Colorschemes |
| `<leader>ut` | 主题选择（fzf-lua，带预览） |

> 在 Picker 中按 `<C-e>` 可将搜索结果输出到 buffer

### LSP

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `gd` | n | 跳转到定义（Snacks Picker） |
| `gD` | n | 跳转到定义（智能分屏） |
| `gr` | n | 查看引用 |
| `gI` | n | 跳转到实现 |
| `gy` | n | 跳转到类型定义 |
| `<leader>rn` | n | LSP 重命名 |
| `<leader>rf` | n | 全文件重命名（无需 LSP） |
| `<leader>yn` | n | 增量预览重命名（inc-rename） |
| `<leader>lf` | n/v | LSP 格式化（支持范围选择） |
| `<leader>sd` | n | 显示诊断浮窗 |
| `<leader>cd` | n | 切换诊断显示开关 |
| `<leader>th` | n | 切换 Inlay Hints |
| `[f` / `]f` | n | 跳转到当前函数开始/结束 |
| `<leader>ch` | n/v | C/C++ 头文件/源文件切换 |

### Git

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>gg` | n | 打开 Lazygit |
| `<leader>gb` | n | Git Branches |
| `<leader>gl` | n | Git Log |
| `<leader>gL` | n | Git Log（当前行） |
| `<leader>gs` | n | Git Status |
| `<leader>gS` | n | Git Stash |
| `<leader>gd` | n | Git Diff（Hunks） |
| `<leader>gf` | n | Git Log（当前文件） |
| `<leader>gB` | n/v | Git Browse（在浏览器打开） |
| `]h` / `[h` | n | 下/上一个 hunk |
| `]H` / `[H` | n | 最后/第一个 hunk |
| `<leader>ggs` | n/v | Stage hunk |
| `<leader>ggr` | n/v | Reset hunk |
| `<leader>ggS` | n | Stage buffer |
| `<leader>ggR` | n | Reset buffer |
| `<leader>ggp` | n | Preview hunk |
| `<leader>ggP` | n | Preview hunk inline |
| `<leader>ggq` | n | Diffs 到 quickfix |
| `<leader>tgb` | n | 切换 git blame |
| `<leader>tgw` | n | 切换 word diff |
| `<leader>to` | n | 切换 mini.diff overlay |

### 调试（DAP）

> 调试器在首次打开 Python / C / C++ / CUDA 文件时懒加载

| 快捷键 / 功能键 | 说明 |
|----------------|------|
| `<leader>ds` / `<F2>` | 开始/继续 |
| `<leader>di` / `<F3>` | Step Into |
| `<leader>do` / `<F4>` | Step Over |
| `<leader>dO` / `<F5>` | Step Out |
| `<leader>dq` | 关闭会话 |
| `<leader>dQ` / `<F7>` | 终止会话 |
| `<leader>dr` | Restart Frame |
| `<leader>db` | 切换断点 |
| `<leader>dB` | 条件断点 |
| `<leader>dD` | 清除所有断点 |
| `<leader>dc` | 运行到光标 |
| `<leader>dR` | 切换 REPL |
| `<leader>dh` | Hover 变量 |
| `<leader>du` / `<F1>` | 切换 DAP UI |

### CMake

| 快捷键 | 说明 |
|--------|------|
| `<leader>cG` / `<leader>cg` | CMake Generate/Configure |
| `<leader>cb` | CMake Build |
| `<leader>cr` | CMake Build & Run |
| `<leader>cd` | CMake Quick Run |
| `<leader>cK` | CMake Select Kit |
| `<leader>ct` | CMake Select Build Type |
| `<leader>cx` | CMake Select Launch Target |
| `<leader>cv` | CMake Select Build Preset |
| `<leader>co` | CMake Open Executor |

### 其他

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `ss` | n/x/o | Flash 跳转 |
| `[c` | n | 跳转到 Treesitter context（上层作用域） |
| `]]` / `[[` | n/t | 下/上一个单词引用（Snacks Words） |
| `<leader>z` | n | 切换 Zen Mode |
| `<leader>Z` | n | 切换 Zoom |
| `<leader>.` | n | 切换 Scratch Buffer |
| `<leader>S` | n | 选择 Scratch Buffer |
| `<leader>n` | n | 通知历史 |
| `<leader>un` | n | 关闭所有通知 |
| `<leader>cR` | n | 重命名文件（Snacks） |
| `<leader>ws` | n | 保存会话 |
| `<leader>wr` | n | 搜索/恢复会话 |
| `<leader>ui` | n | Inspect 光标位置 |
| `<leader>uI` | n | Inspect Treesitter 树 |
| `<c-/>` | n/i/t | 切换浮动终端 |
| `<leader>mc` | n | 插入 Markdown 代码块（Markdown 文件中） |

### mini.surround

| 快捷键 | 说明 |
|--------|------|
| `sa` | 添加包围符 |
| `sd` | 删除包围符 |
| `sr` | 替换包围符 |
| `sf` | 查找包围符（向右） |
| `sF` | 查找包围符（向左） |
| `sh` | 高亮包围符 |

### Windsurf（Codeium AI 补全）

> 在插入模式下触发

| 快捷键 | 说明 |
|--------|------|
| `<C-g>` | 接受补全 |
| `<C-h>` | 接受下一个单词 |
| `<C-j>` | 接受下一行 |
| `<C-;>` | 切换下一个补全 |
| `<C-,>` | 切换上一个补全 |
| `<C-x>` | 清除补全 |

---

## 通用函数（`config/utils.lua`）

| 函数 | 说明 |
|------|------|
| `M.is_lsp_attached()` | 检测当前 buffer 是否有 LSP 客户端附加 |
| `M.is_mac()` | 检测当前系统是否为 macOS |
| `M.func_on_window(window_name, fn)` | 在特定 filetype 的窗口上执行函数 |
| `M.open_grep_results(items)` | 将 Snacks Picker 的搜索结果输出为可交互 buffer（`<CR>` 跳转，`q` 关闭） |
| `M.reset_overseerlist_width()` | 将 OverseerList 窗口宽度重置为屏幕的 20% |

---

## 自动命令（`config/autocmds.lua`）

| 触发事件 | 功能 |
|----------|------|
| `FocusGained` / `TermClose` / `TermLeave` | 自动检查文件是否被外部修改（`checktime`） |
| `TextYankPost` | 复制时高亮闪烁 |
| `VimResized` | 窗口大小变化时均匀分配分屏尺寸 |
| `BufReadPost` | 恢复上次光标位置 |
| `FileType` | 对特殊 buffer（help/qf/notify 等）绑定 `q` 关闭 |
| `FileType markdown/text/...` | 启用换行，关闭拼写检查 |
| `FileType json/jsonc/json5` | 禁用 conceallevel（原样显示 JSON） |
| `BufWritePre` | 保存时自动格式化（跳过 C/C++/QML） |
| `BufWritePre` | 自动创建父目录（保存时若目录不存在则创建） |
| `ColorScheme` | 切换主题后覆盖状态栏高亮（透明背景，注释不斜体） |
| `LspAttach` | 绑定 LSP 快捷键；按需启用 LSP 折叠；显示诊断浮窗 |
| `FileType markdown` | 懒加载 render-markdown.nvim |

---

## 插件说明

### UI / 外观

| 插件 | 说明 |
|------|------|
| **catppuccin/nvim** 等 | 多套主题，持久化记录最后选择，启动时自动恢复 |
| **nvim-web-devicons** | 文件类型图标 |
| **mini.icons** | 替代/补充 devicons 的图标库 |
| **heirline.nvim** | 高度可定制状态栏，懒加载于首次读取文件时 |
| **lsp-progress.nvim** | 状态栏中显示 LSP 进度 |
| **bufferline.nvim** | 顶部 Buffer 标签栏，集成 LSP 诊断图标 |
| **noice.nvim** | 重写命令行、通知、LSP 文档显示 UI |
| **nui.nvim** | noice 的 UI 组件依赖 |

### 搜索 / 导航

| 插件 | 说明 |
|------|------|
| **snacks.nvim** | 多功能瑞士军刀：Picker（模糊搜索）、notifier、indent、zen、scroll、terminal 等 |
| **fzf-lua** | 主题选择器（`<leader>ut`）的后端 |
| **flash.nvim** | 快速跳转，`ss` 激活（懒加载到首次使用时） |
| **which-key.nvim** | 快捷键提示弹窗，helix 风格预设 |

### 文件管理

| 插件 | 说明 |
|------|------|
| **oil.nvim** | 像编辑文本一样编辑目录，替代 netrw，`<leader>e` 打开 |
| **yazi.nvim** | 集成 yazi 终端文件管理器，`tt` 打开，按需懒加载 |

### LSP / 补全

| 插件 | 说明 |
|------|------|
| **mason.nvim** | LSP 服务器安装管理器 |
| **mason-lspconfig.nvim** | 自动安装 ensure_installed 列表中的 LSP |
| **nvim-lspconfig** | LSP 客户端配置框架 |
| **blink.cmp** | 现代高性能补全引擎，懒加载于首次进入插入/命令行模式 |
| **blink-cmp-words** | blink.cmp 的单词/词典补全源（Markdown/text 专用） |
| **inc-rename.nvim** | 增量预览重命名，`<leader>yn` 触发 |

支持的 LSP：`clangd`（C/C++）、`pyright`（Python）、`cmake`、`bashls`、`jsonls`、`lua_ls`、`qmlls`

### 语法 / 代码

| 插件 | 说明 |
|------|------|
| **nvim-treesitter** | 语法高亮、缩进，启动时安装预设 parser |
| **nvim-treesitter-context** | 顶部显示当前所在函数/类上下文，`[c` 跳转到上层作用域 |
| **nvim-autopairs** | 自动补全括号/引号，懒加载于首次进入插入模式 |
| **nvim-surround** | 快速操作包围符（括号、引号等） |
| **mini.ai** | 增强文本对象（`[`/`]` 跳转） |
| **mini.surround** | mini 系列的包围符操作 |

### Git

| 插件 | 说明 |
|------|------|
| **gitsigns.nvim** | 行号列 git 状态、blame、hunk 操作，懒加载于首次读取文件 |
| **mini.diff** | diff overlay 展示，`<leader>to` 切换，懒加载于首次读取文件 |

### 调试（DAP）

| 插件 | 说明 |
|------|------|
| **nvim-dap** | DAP 调试核心 |
| **nvim-dap-ui** | 调试 UI 面板（变量、堆栈、断点、REPL） |
| **nvim-dap-virtual-text** | 内联显示变量值 |
| **nvim-dap-python** | Python 调试适配器 |
| **nvim-nio** | dap-ui 的异步 IO 依赖 |

支持的调试适配器：`codelldb`（C/C++ 推荐）、`cppdbg`（OpenDebugAD7）、`gdb`、`cuda-gdb`、`python`

### 其他工具

| 插件 | 说明 |
|------|------|
| **auto-session** | 自动保存/恢复 session，`<leader>ws` 保存，`<leader>wr` 搜索 |
| **cmake-tools.nvim** | CMake 工作流集成，`<leader>c` 前缀快捷键 |
| **render-markdown.nvim** | Markdown 美化渲染，懒加载于 FileType markdown |
| **image.nvim** | Markdown 中内嵌图片渲染（kitty 后端） |
| **windsurf.vim** | Codeium/Windsurf AI 代码补全（`<C-g>` 接受） |
| **vim-tmux-navigator** | tmux 环境下 nvim 窗口与 tmux pane 无缝切换 |
| **plenary.nvim** | Lua 工具库，部分插件的依赖 |

---

## LSP 配置

通过 Mason 自动安装以下语言服务器：

```
clangd    → C / C++
pyright   → Python
cmake     → CMakeLists.txt
bashls    → Shell Script
jsonls    → JSON
lua_ls    → Lua（含 nvim API 全局变量识别）
qmlls     → QML（Qt）
```

诊断配置：
- 仅在当前行显示虚拟文本（`virtual_text = { current_line = true }`）
- 按严重程度排序
- 自定义诊断图标（Error / Warn / Info / Hint）

代码折叠优先级：LSP foldingRange > Treesitter 表达式折叠

---

## 主题系统

- 内置多套主题：`catppuccin`、`tokyonight`、`gruvbox`、`kanagawa`、`rose-pine`、`onedark`、`everforest`、`astrotheme`
- 默认主题：`catppuccin`
- 通过 `<leader>ut`（fzf-lua）选择主题，带实时预览
- 主题选择持久化到 `$XDG_STATE_HOME/nvim/last_colorscheme`，下次启动自动恢复
- 切换主题时自动覆盖：状态栏透明背景，注释不斜体
