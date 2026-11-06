# Neovim 快捷键迁移说明

根据 ~/.config/nvim 中实际加载的 Lua 配置迁移，不是套用通用的 LazyVim 键位。
Neovim 配置未修改，Zed 的主题、模型等设置未修改；另外开启了内置 Which-key 菜单，延迟 300 毫秒。
原 Zed 快捷键配置保存在同目录 keymap.before-nvim.json，恢复时可将其内容还原到 keymap.json。

## 用法

Leader 是空格。以下 `Space ff` 表示依次按空格、f、f，`H` 表示 Shift+h。
编辑快捷键仅在代码编辑区的 Vim 普通模式生效；特别注明的还支持可视/插入模式。
不在搜索框、命令面板或 AI 输入框中启用 Leader，以免干扰正常输入。

| 快捷键 | Zed 中的行为 |
| --- | --- |
| kj / KJ | 插入模式退回普通模式 |
| Ctrl+1 ... Ctrl+9 / Ctrl+0 | 补全列表显示时接受第 1 ... 9 / 10 个候选；Zed 不一定显示候选序号 |
| ss | 可视单词标签跳转，保留此前选择；不是完整 Flash |
| sa / sd / sr | 添加 / 删除 / 替换包围符号 |
| Alt+j / Alt+k | 下移 / 上移当前行或选区，不额外自动重缩进 |
| j / k | 无计数按视觉行移动，有计数按物理行移动 |
| H / L | 上一个 / 下一个当前窗格标签 |
| Ctrl+h / Ctrl+l | 向左 / 向右切换焦点，支持编辑区分屏和已打开的左侧文件树；文件树中 Ctrl+l 返回编辑区 |
| Space w | 保存 |
| Space q | 关闭当前标签，未保存时会提示 |
| Space qq | 使用与 Vim :wqa 相同的原生动作，保存并关闭当前工作区全部项目项，不退出整个 Zed |
| Space bd / bD | 关闭当前标签 |
| Space bO | 关闭当前窗格的其他标签 |
| Space bp / fb / , | 当前窗格标签选择器 |
| Space Space / ff / fr | 文件查找器，包含最近文件；fr 不是严格的仅最近文件列表 |
| Space fp / wr | 最近项目列表，不是 AutoSession 的会话管理 |
| Space e / - | 聚焦文件树；文件树中再次按下返回编辑区 |
| Space / / sg | 项目搜索 |
| Space sw | 打开项目搜索，用当前单词/选区预填查询并禁用正则，需确认查询；已有文件搜索时可能沿用其查询 |
| Space sb | 当前文件搜索，不是 Snacks 行选择器 |
| Space : / sc / sC | 命令面板，不是单独的 Neovim 命令历史 |
| Space sk | 打开快捷键配置文件，不是 Snacks 快捷键选择器 |
| Space sR | 重新打开上一个选择器 |
| Space ss / sS | 当前文件 / 项目符号 |
| Space xs | 大纲面板 |
| Space xx / sd | 项目诊断列表 |
| Space xd | 悬停信息，可能含诊断，也可能含类型文档 |
| Space rn | LSP 重命名，无 inc-rename 的逐字预览保证 |
| Space ca | 代码操作，普通/可视模式 |
| Space cf | 格式化文件；可视模式格式化选区 |
| Space ch | C/C++ 头文件与源文件切换，普通/可视模式 |
| Space th | 切换内联类型提示 |
| gr | 所有引用 |
| [[ / ]] | 上一个 / 下一个符号引用 |
| Space - / Space \| | 向下 / 向右分屏 |
| Space wd | 关闭当前标签，不保证删除整个分屏 |
| Ctrl+方向键 | 调整窗格大小，步长由 Zed 决定 |
| Space Z | 缩放当前面板/窗格 |
| Space . | 新建未命名文件，不是持久化的 Snacks Scratch |
| Space us / uC | 主题选择器 |
| Space gb | Git 分支选择器 |
| Space gs / gd | Git 面板 / Git 差异 |
| Space ggp / ggP | 展开/收起当前差异块 |
| Space ggs | 切换当前块暂存状态，不是始终执行暂存 |
| Space ggS | 暂存当前文件 |
| Ctrl+/ / Ctrl+_ | 切换终端，普通/可视/插入及终端中可用 |
| Space oo | 任务选择器，不是 Overseer 的任务列表面板 |
| Space or | 重跑最近任务 |
| Space co | 显示/隐藏终端输出面板 |
| Space cb / cg / cr | 运行带 build / configure / run 标签的项目任务 |
| Space cD | 打开调试配置选择器；是否先构建由项目 debug.json 决定 |

## 调试

| 快捷键 | 行为 |
| --- | --- |
| F1 / Space du | 聚焦或离开调试面板，不保证与 DAP UI 显隐完全相同 |
| F2 / Space ds | 启动调试选择器；暂停在断点时继续 |
| F3 / Space di | 步入 |
| F4 / Space do | 步过 |
| F5 / Space dO | 步出 |
| F6 | 重启当前调试会话 |
| F7 / Space dQ | 停止当前调试会话 |
| Space db | 切换当前行断点 |
| Space dD | 清除项目中的全部断点 |
| Space dc | 运行到光标，须已处于暂停的调试会话中 |
| Space dR | 聚焦调试控制台 |

F1-F7 在代码普通模式与调试面板生效，会覆盖 Zed 默认的 F2 重命名、F3 搜索等。
程序运行中如需暂停，请使用调试界面的暂停按钮。

## 任务约定

示例项目 ~/项目/zed-cpp-playground 已补齐任务标签，可直接试 Space cb / cg / cr。
其他项目需在 .zed/tasks.json 中为对应任务添加 tags，例如：

```json
{
  "label": "Build",
  "command": "cmake --build build",
  "tags": ["build"],
  "save": "all"
}
```

这不是自动识别所有项目类型的 Neovim build 后端。没有对应标签就不会运行目标任务。

## 未强行迁移的功能

- Flash 的搜索标签、Treesitter 跳转、远程选择；ss 仅保留 Helix 标签近似方案。
- mini.surround 的 sf/sF/sh/sn 和 next/last 后缀；sa/sd/sr 使用 Zed 的 surround 语义，边界搜索可能不同。
- Oil 可编辑目录、Snacks 仪表盘、Which-key 自定义分组、寄存器/撤销树/Quickfix 等选择器。
- Neovim 的 [f / ]f 当前函数边界自定义逻辑，避免误映射成 Zed 的“下一个函数”。
- 缓冲区级诊断过滤、诊断开关、条件断点输入、重启栈帧、关闭 DAP 连接等没有核实等价操作的键位。
- Sidekick AI CLI、Codeium 建议接受/切换，以及 Blink 的完整 super-tab 优先级；不假设你在 Zed 使用相同 AI 服务。仅迁移补全候选数字选择。
- 自动会话保存、Conan/CMake/Python 后端自动检测、Git 插件的额外工作流。
- Ctrl+h/l 已补为 Zed 内部左右导航，不支持跨 tmux 窗格；Ctrl+j/k 未改。插入模式不覆盖 Ctrl+h 的退格行为。

Zed 自带的 gd、gD、gI、gy、K、[d、]d、gcc、Ctrl+w 分屏操作仍沿用默认 Vim 行为。
范围格式化需要当前语言服务器/格式化工具支持，不能保证所有语言都可用。
Space w 同时是 Space wd / wr 的前缀，Space q 同时是 Space qq 的前缀，
Zed 会等待后续键；需要立即保存可按 :w Enter 或 Ctrl+s（普通模式）。
按空格等快捷键前缀后等待 300 毫秒，会显示 Zed 内置 Which-key 菜单。
已禁用普通/可视模式中单独空格的默认移动动作，让空格只作为 Leader；但当前窗口仍有菜单超时反馈，尚未确认实际触发超时的原因。
自动弹出的 Which-key 菜单本身不暂停快捷键计时。Leader 序列等待期间可以按 Alt+/ 手动打开待选快捷键提示列表，该列表打开期间暂停计时。
Alt+/ 已在代码普通/可视模式中显式绑定，不等同于 Neovim 的自定义 Which-key 分组。
keymap 通常自动重载；实际 UI 交互仍需在你的 Zed 窗口中体验验证。
