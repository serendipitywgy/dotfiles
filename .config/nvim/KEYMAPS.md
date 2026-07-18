# Neovim 快捷键速查

> Leader 键为 `<Space>`

---

## 文件 / 搜索

| 快捷键 | 功能 |
|---|---|
| `<leader><space>` | 智能查找文件 |
| `<leader>ff` | 查找文件 |
| `<leader>fg` | 查找 Git 文件 |
| `<leader>fr` | 最近打开的文件 |
| `<leader>fp` | 项目列表 |
| `<leader>fc` | 查找 Neovim 配置文件 |
| `<leader>/` | 全局 Grep 搜索 |
| `<leader>sg` | 全局 Grep 搜索 |
| `<leader>sw` | 搜索当前单词 / 选中内容 |
| `<leader>sb` | 搜索当前 buffer 的行 |
| `<leader>sB` | 搜索所有已打开 buffer |

---

## Buffer 管理

| 快捷键 | 功能 |
|---|---|
| `<S-h>` | 切换到上一个 buffer |
| `<S-l>` | 切换到下一个 buffer |
| `<leader>,` | 列出所有 buffer（可搜索跳转） |
| `<leader>fb` | 列出所有 buffer（同上） |
| `<leader>bd` | 删除当前 buffer |
| `<leader>bD` | 删除当前 buffer 并关闭窗口 |
| `<leader>bp` | 字母跳转到指定 buffer（bufferline） |
| `<leader>bc` | 字母选择并关闭指定 buffer（bufferline） |

### 在 buffer 列表（`<leader>fb`）里的操作

| 按键 | 功能 |
|---|---|
| `Tab` | 多选标记当前条目 |
| `<C-d>` | 删除选中的 buffer（无多选则删除当前条目） |
| `<Enter>` | 跳转到选中 buffer |

---

## 窗口

| 快捷键 | 功能 |
|---|---|
| `<C-h/j/k/l>` | 在窗口间移动（支持跨 tmux pane） |
| `<leader>-` | 水平分割窗口 |
| `<leader>\|` | 垂直分割窗口 |
| `<leader>wd` | 关闭当前窗口 |
| `<C-↑/↓>` | 调整窗口高度 |
| `<C-←/→>` | 调整窗口宽度 |

---

## 编辑

| 快捷键 | 功能 |
|---|---|
| `<leader>w` | 保存文件 |
| `<leader>q` | 退出当前 buffer |
| `<leader>qq` | 保存所有并退出 |
| `<leader>lf` | LSP 格式化（支持可视区域） |
| `<leader>rn` | LSP 重命名（弹窗输入） |
| `<leader>yn` | 增量重命名（实时预览） |
| `<leader>rf` | 全文件替换当前单词 |
| `<leader>cR` | 重命名当前文件 |
| `<leader>ch` | 头文件 / 源文件切换（C/C++） |
| `kj` / `KJ` | 退出插入模式（同 `<Esc>`） |
| `<Esc>` | 清除搜索高亮 |

### Surround（mini.surround）

| 快捷键 | 功能 |
|---|---|
| `sa` | 添加包围符 |
| `sd` | 删除包围符 |
| `sr` | 替换包围符 |
| `sf` / `sF` | 查找右 / 左包围符 |
| `sh` | 高亮包围符 |
| `sn` | 更新查找范围行数 |

---

## LSP / 代码跳转

| 快捷键 | 功能 |
|---|---|
| `gd` | 跳转到定义 |
| `gD` | 跳转到声明 |
| `gr` | 查看引用 |
| `gI` | 跳转到实现 |
| `gy` | 跳转到类型定义 |
| `[f` | 跳转到当前函数开头 |
| `]f` | 跳转到当前函数结尾 |
| `<leader>ss` | LSP 符号列表 |
| `<leader>sS` | LSP 工作区符号 |
| `<leader>sd` | 显示诊断浮窗 |
| `<leader>sD` | 当前 buffer 的诊断列表 |
| `<leader>cd` | 切换诊断显示开/关 |
| `<leader>th` | 切换 Inlay Hints 开/关 |
| `]]` / `[[` | 跳转到下/上一个引用 |

---

## Flash 快速跳转

| 快捷键 | 功能 |
|---|---|
| `ss` | Flash 跳转（输入字符高亮跳转目标） |

---

## Git

| 快捷键 | 功能 |
|---|---|
| `<leader>gg` | 打开 Lazygit |
| `<leader>gb` | Git 分支列表 |
| `<leader>gl` | Git 提交日志 |
| `<leader>gs` | Git 状态 |
| `<leader>gd` | Git Diff Hunks |
| `<leader>gB` | 在浏览器打开当前文件的 Git 页面 |
| `]h` / `[h` | 跳转到下/上一个 hunk |
| `]H` / `[H` | 跳转到最后/第一个 hunk |
| `<leader>ggs` | Stage 当前 hunk（支持可视模式） |
| `<leader>ggr` | Reset 当前 hunk（支持可视模式） |
| `<leader>ggS` | Stage 整个 buffer |
| `<leader>ggR` | Reset 整个 buffer |
| `<leader>ggp` | 预览 hunk |
| `<leader>ggP` | 行内预览 hunk |
| `<leader>ggq` | 当前文件 diff 到 quickfix |
| `<leader>ggQ` | 所有 diff 到 quickfix |
| `<leader>ga` | 行注释 |
| `<leader>gw` | 逐词高亮 |
| `<leader>go` | 改动对比 |
| `ih` | 选中当前 hunk（文本对象） |

---

## CMake

| 快捷键 | 功能 |
|---|---|
| `<leader>cG` | 生成（Generate） |
| `<leader>cg` | 配置（Configure） |
| `<leader>cb` | 构建（Build） |
| `<leader>cr` | 构建并运行 |
| `<leader>cd` | 构建并调试 |
| `<leader>ct` | 选择构建类型 |
| `<leader>cK` | 选择工具链（Kit） |
| `<leader>cx` | 选择启动目标 |
| `<leader>cv` | 选择构建预设 / Variant |
| `<leader>co` | 打开执行器 |

---

## 调试（DAP）

| 快捷键 | 功能 |
|---|---|
| `<leader>du` / `<F1>` | 切换 DAP UI |
| `<leader>ds` / `<F2>` | 开始 / 继续 |
| `<leader>di` / `<F3>` | 步入 |
| `<leader>do` / `<F4>` | 步过 |
| `<leader>dO` / `<F5>` | 步出 |
| `<leader>dr` / `<F6>` | 重启帧 |
| `<leader>dQ` / `<F7>` | 终止会话 |
| `<leader>dq` | 关闭会话 |
| `<leader>dc` | 运行到光标处 |
| `<leader>dR` | 切换 REPL |
| `<leader>dh` | 悬浮变量查看 |
| `<leader>db` | 切换断点 |
| `<leader>dB` | 设置条件断点 |
| `<leader>dD` | 清除所有断点 |

---

## 会话管理

| 快捷键 | 功能 |
|---|---|
| `<leader>ws` | 保存当前会话 |
| `<leader>wr` | 搜索 / 恢复会话 |

---

## 文件管理

| 快捷键 | 功能 |
|---|---|
| `<leader>e` | 打开 Oil 文件浏览器 |
| `tt` | 打开 Yazi 文件管理器 |

### Oil 内部按键

| 按键 | 功能 |
|---|---|
| `h` | 进入上级目录 |
| `l` | 进入目录 / 打开文件 |
| `zh` | 切换隐藏文件显示 |
| `gd` | 切换文件详情（权限/大小/时间） |
| `<C-r>` | 刷新 |
| `<leader>y` | 复制路径 |
| `\` | 横向分割打开 |
| `\|` | 纵向分割打开 |
| `-` | 关闭 Oil |

---

## 终端

| 快捷键 | 功能 |
|---|---|
| `<C-/>` | 打开 / 关闭浮动终端 |

---

## UI / 工具

| 快捷键 | 功能 |
|---|---|
| `<leader>z` | Zen 模式 |
| `<leader>Z` | Zoom 当前窗口 |
| `<leader>.` | 打开 Scratch Buffer |
| `<leader>uC` | 切换配色方案（Snacks picker） |
| `<leader>ut` | 切换配色方案（fzf-lua） |
| `<leader>utp` | 切换透明模式 |
| `<leader>n` | 通知历史 |
| `<leader>un` | 关闭所有通知 |
| `<leader>ui` | 查看光标位置的高亮信息 |
| `<leader>uI` | 查看 Treesitter 语法树 |
| `<leader>:` | 命令历史 |
| `<leader>sk` | 快捷键列表 |
| `<leader>sh` | 帮助文档搜索 |
| `S` | 查看当前 buffer 的 which-key |

### Markdown（render-markdown）

| 快捷键 | 功能 |
|---|---|
| `<leader>mc` | 插入代码块 |

---

## AI 补全（Codeium）

| 快捷键 | 功能 |
|---|---|
| `<C-g>`（插入模式） | 接受补全 |
| `<C-h>`（插入模式） | 接受下一个单词 |
| `<C-j>`（插入模式） | 接受下一行 |
| `<C-;>`（插入模式） | 下一个补全候选 |
| `<C-,>`（插入模式） | 上一个补全候选 |
| `<C-x>`（插入模式） | 清除补全 |

### blink.cmp 补全窗口内

| 按键 | 功能 |
|---|---|
| `<C-u>` | 文档上滚 |
| `<C-d>` | 文档下滚 |
| `<A-1>` ~ `<A-0>` | 直接选择第 1~10 个候选项 |
