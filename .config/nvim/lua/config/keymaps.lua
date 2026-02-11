-- 定义一个函数来设置多个键映射
local function set_keymaps(mode, keymaps, target, opts)
    for _, keymap in ipairs(keymaps) do
        vim.keymap.set(mode, keymap, target, opts)
    end
end

-- -- 定义诊断提示状态变量
-- local diagnostics_enabled = true
--
-- -- 绑定快捷键（例如 <leader>dt）
-- set_keymaps("n", { "<leader>cd" }, function()
--   if diagnostics_enabled then
--     vim.diagnostic.enable(false) -- 更新：禁用诊断
--     print("Diagnostics disabled")
--   else
--     vim.diagnostic.enable(true)  -- 更新：启用诊断 (或者直接用 vim.diagnostic.enable())
--     print("Diagnostics enabled")
--   end
--   diagnostics_enabled = not diagnostics_enabled
-- end, { desc = "是否开启诊断显示" })

-- 基础导航增强,目的：在长行自动换行时可以按视觉行而不是实际行移动
set_keymaps({ "n", "x" }, { "j" }, "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
set_keymaps({ "n", "x" }, { "k" }, "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- 插入模式下，按下 kj 或 KJ 不执行任何操作
set_keymaps("i", { "kj", "KJ" }, "<Esc>", { silent = true })

-- 窗口导航
set_keymaps("n", { "<C-h>" }, "<C-w>h", { desc = "Go to Left Window", remap = true })
set_keymaps("n", { "<C-j>" }, "<C-w>j", { desc = "Go to Lower Window", remap = true })
set_keymaps("n", { "<C-k>" }, "<C-w>k", { desc = "Go to Upper Window", remap = true })
set_keymaps("n", { "<C-l>" }, "<C-w>l", { desc = "Go to Right Window", remap = true })

-- buffer的更换
set_keymaps("n", { "<S-h>" }, "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
set_keymaps("n", { "<S-l>" }, "<cmd>bnext<cr>", { desc = "Next Buffer" })
set_keymaps("n", { "<leader>bD" }, "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- lazy
-- set_keymaps("n", { "<leader>l" }, "<cmd>Lazy<cr>", { desc = "Lazy" })

--lsp formatting
-- set_keymaps({ "n" }, { "<leader>lf" }, function() vim.lsp.buf.format() end, { desc = "lsp格式化" })

set_keymaps({ "n", "v" }, { "<leader>lf" }, function()
    -- 获取当前模式
    local mode = vim.api.nvim_get_mode().mode
    if mode == "v" or mode == "V" or mode == " " then
        -- 如果是可视模式，获取选中的起始和结束位置
        local start_pos = vim.fn.getpos("v")
        local end_pos = vim.fn.getpos(".")

        vim.lsp.buf.format({
            range = {
                ["start"] = { start_pos[2], start_pos[3] - 1 },
                ["end"] = { end_pos[2], end_pos[3] - 1 },
            }
        })
        -- 格式化后跳回普通模式
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
    else
        -- 普通模式下默认格式化整个文件
        vim.lsp.buf.format({ async = true })
    end
end, { desc = "LSP格式化 (支持范围)" })
-- quit
set_keymaps("n", { "<leader>qq" }, "<cmd>wqa<cr>", { desc = "Quit All" })
set_keymaps("n", { "<leader>w" }, "<cmd>w<cr>", { desc = "保存当前Buffer", nowait = true })
set_keymaps("n", { "<leader>q" }, "<cmd>q<cr>", { desc = "退出当前Buffer", nowait = true }) -- nowait: 不延迟

-- highlights under cursor
set_keymaps("n", { "<leader>ui" }, vim.show_pos, { desc = "Inspect Pos" })
set_keymaps("n", { "<leader>uI" }, function()
    vim.treesitter.inspect_tree()
    vim.api.nvim_input("I")
end, { desc = "Inspect Tree" })

-- Terminal Mappings
set_keymaps("t", { "<C-/>" }, "<cmd>close<cr>", { desc = "Hide Terminal" })
-- set_keymaps("t", {"<c-_>"}, "<cmd>close<cr>", { desc = "which_key_ignore" })

-- windows
set_keymaps("n", { "<leader>-" }, "<C-W>s", { desc = "Split Window Below", remap = true })
set_keymaps("n", { "<leader>|" }, "<C-W>v", { desc = "Split Window Right", remap = true })
set_keymaps("n", { "<leader>wd" }, "<C-W>c", { desc = "Delete Window", remap = true })
-- Resize window using <ctrl> arrow keys
set_keymaps("n", { "<C-Up>" }, "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
set_keymaps("n", { "<C-Down>" }, "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
set_keymaps("n", { "<C-Left>" }, "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
set_keymaps("n", { "<C-Right>" }, "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
--头文件/源文件切换
set_keymaps({ "v", "n" }, { "<leader>ch" }, "<cmd>LspClangdSwitchSourceHeader<CR>", { silent = true })

--清除搜索高亮
set_keymaps("n", { "<Esc>" }, "<cmd>nohlsearch<CR>", { silent = true })

--snacks的快捷键
-- 通用
-- set_keymaps("n", { "<leader>e" }, function() Snacks.explorer() end, { desc = "File Explorer" })
set_keymaps("n", { "<leader><space>" }, function() Snacks.picker.smart() end, { desc = "Smart Find Files" })
set_keymaps("n", { "<leader>," }, function() Snacks.picker.buffers() end, { desc = "Buffers" })
set_keymaps("n", { "<leader>/" }, function() Snacks.picker.grep() end, { desc = "Grep" })
set_keymaps("n", { "<leader>:" }, function() Snacks.picker.command_history() end, { desc = "Command History" })
set_keymaps("n", { "<leader>n" }, function() Snacks.picker.notifications() end, { desc = "Notification History" })

-- find
set_keymaps("n", { "<leader>fb" }, function() Snacks.picker.buffers() end, { desc = "Buffers" })
set_keymaps("n", { "<leader>fc" }, function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,
    { desc = "Find Config File" })
set_keymaps("n", { "<leader>ff" }, function() Snacks.picker.files() end, { desc = "Find Files" })
set_keymaps("n", { "<leader>fg" }, function() Snacks.picker.git_files() end, { desc = "Find Git Files" })
set_keymaps("n", { "<leader>fp" }, function() Snacks.picker.projects() end, { desc = "Projects" })
set_keymaps("n", { "<leader>fr" }, function() Snacks.picker.recent() end, { desc = "Recent" })

-- git
set_keymaps("n", { "<leader>gb" }, function() Snacks.picker.git_branches() end, { desc = "Git Branches" })
set_keymaps("n", { "<leader>gl" }, function() Snacks.picker.git_log() end, { desc = "Git Log" })
set_keymaps("n", { "<leader>gL" }, function() Snacks.picker.git_log_line() end, { desc = "Git Log Line" })
set_keymaps("n", { "<leader>gs" }, function() Snacks.picker.git_status() end, { desc = "Git Status" })
set_keymaps("n", { "<leader>gS" }, function() Snacks.picker.git_stash() end, { desc = "Git Stash" })
set_keymaps("n", { "<leader>gd" }, function() Snacks.picker.git_diff() end, { desc = "Git Diff (Hunks)" })
set_keymaps("n", { "<leader>gf" }, function() Snacks.picker.git_log_file() end, { desc = "Git Log File" })

-- grep / search
set_keymaps("n", { "<leader>sb" }, function() Snacks.picker.lines() end, { desc = "Buffer Lines" })
set_keymaps("n", { "<leader>sB" }, function() Snacks.picker.grep_buffers() end, { desc = "Grep Open Buffers" })
set_keymaps("n", { "<leader>sg" }, function() Snacks.picker.grep() end, { desc = "Grep" })
set_keymaps({ "n", "x" }, { "<leader>sw" }, function() Snacks.picker.grep_word() end,
    { desc = "Visual selection or word" })

set_keymaps("n", { '<leader>s"' }, function() Snacks.picker.registers() end, { desc = "Registers" })
set_keymaps("n", { "<leader>s/" }, function() Snacks.picker.search_history() end, { desc = "Search History" })
set_keymaps("n", { "<leader>sa" }, function() Snacks.picker.autocmds() end, { desc = "Autocmds" })
set_keymaps("n", { "<leader>sc" }, function() Snacks.picker.command_history() end, { desc = "Command History" })
set_keymaps("n", { "<leader>sC" }, function() Snacks.picker.commands() end, { desc = "Commands" })
set_keymaps("n", { "<leader>sd" }, function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
set_keymaps("n", { "<leader>sD" }, function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
set_keymaps("n", { "<leader>sh" }, function() Snacks.picker.help() end, { desc = "Help Pages" })
set_keymaps("n", { "<leader>sH" }, function() Snacks.picker.highlights() end, { desc = "Highlights" })
set_keymaps("n", { "<leader>si" }, function() Snacks.picker.icons() end, { desc = "Icons" })
set_keymaps("n", { "<leader>sj" }, function() Snacks.picker.jumps() end, { desc = "Jumps" })
set_keymaps("n", { "<leader>sk" }, function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
set_keymaps("n", { "<leader>sl" }, function() Snacks.picker.loclist() end, { desc = "Location List" })
set_keymaps("n", { "<leader>sm" }, function() Snacks.picker.marks() end, { desc = "Marks" })
set_keymaps("n", { "<leader>sM" }, function() Snacks.picker.man() end, { desc = "Man Pages" })
set_keymaps("n", { "<leader>sp" }, function() Snacks.picker.lazy() end, { desc = "Search for Plugin Spec" })
set_keymaps("n", { "<leader>sq" }, function() Snacks.picker.qflist() end, { desc = "Quickfix List" })
set_keymaps("n", { "<leader>sR" }, function() Snacks.picker.resume() end, { desc = "Resume" })
set_keymaps("n", { "<leader>su" }, function() Snacks.picker.undo() end, { desc = "Undo History" })

-- ui
set_keymaps("n", { "<leader>uC" }, function() Snacks.picker.colorschemes() end, { desc = "Colorschemes" })
set_keymaps("n", { "gd" }, function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
set_keymaps("n", { "gD" }, function() Snacks.picker.lsp_declarations() end, { desc = "Goto Declaration" })
set_keymaps("n", { "gr" }, function() Snacks.picker.lsp_references() end, { nowait = true, desc = "References" })
set_keymaps("n", { "gI" }, function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
set_keymaps("n", { "gy" }, function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto T[y]pe Definition" })
set_keymaps("n", { "<leader>ss" }, function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
set_keymaps("n", { "<leader>sS" }, function() Snacks.picker.lsp_workspace_symbols() end,
    { desc = "LSP Workspace Symbols" })

--snacks---other
-- Zen / Zoom
set_keymaps("n", { "<leader>z" }, function() Snacks.zen() end, { desc = "Toggle Zen Mode" })
set_keymaps("n", { "<leader>Z" }, function() Snacks.zen.zoom() end, { desc = "Toggle Zoom" })

-- Scratch
set_keymaps("n", { "<leader>." }, function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
set_keymaps("n", { "<leader>S" }, function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })

-- Notifications
set_keymaps("n", { "<leader>n" }, function() Snacks.notifier.show_history() end, { desc = "Notification History" })
set_keymaps("n", { "<leader>un" }, function() Snacks.notifier.hide() end, { desc = "Dismiss All Notifications" })

-- Buffer / File
set_keymaps("n", { "<leader>bd" }, function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
set_keymaps("n", { "<leader>cR" }, function() Snacks.rename.rename_file() end, { desc = "Rename File" })

-- Git
set_keymaps("n", { "<leader>gg" }, function() Snacks.lazygit() end, { desc = "Lazygit" })
set_keymaps({ "n", "v" }, { "<leader>gB" }, function() Snacks.gitbrowse() end, { desc = "Git Browse" })

-- Terminal
set_keymaps({ "n", "i", "t" }, { "<c-/>" }, function() Snacks.terminal() end, { desc = "Toggle Terminal" })
set_keymaps({ "n", "i", "t" }, { "<c-_>" }, function() Snacks.terminal() end, { desc = "which_key_ignore" })

-- Word references jump
set_keymaps("n", { "]]" }, function() Snacks.words.jump(vim.v.count1) end, { desc = "Next Reference" })
set_keymaps("n", { "[[" }, function() Snacks.words.jump(-vim.v.count1) end, { desc = "Prev Reference" })
set_keymaps("t", { "]]" }, function() Snacks.words.jump(vim.v.count1) end, { desc = "Next Reference" })
set_keymaps("t", { "[[" }, function() Snacks.words.jump(-vim.v.count1) end, { desc = "Prev Reference" })

--flash
-- set_keymaps({ "n", "x", "o" }, { "s" }, function() require("flash").jump() end, { desc = "Flash" })
set_keymaps({ "n", "x", "o" }, { "ss" }, function()
    -- 只在第一次用到时加载 flash.nvim
    if not package.loaded["flash"] then
        require("flash").setup({})
    end
    require("flash").jump()
end, { desc = "Flash" })

set_keymaps({ "n", "x", "o" }, { "S" }, function() require("which-key").show({ global = false }) end,
    { desc = "Buffer Local Keymaps (which-key)" })

--which-key

set_keymaps({ "n", "x", "o" }, { "<leader>?" }, function() require("flash").jump() end, { desc = "which_key查询" })



set_keymaps("i", { "<C-g>" }, function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
set_keymaps("i", { "<C-h>" }, function() return vim.fn['codeium#AcceptNextWord']() end, { expr = true, silent = true })
set_keymaps("i", { "<C-j>" }, function() return vim.fn['codeium#AcceptNextLine']() end, { expr = true, silent = true })
set_keymaps("i", { "<C-;>" }, function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
set_keymaps("i", { "<C-,>" }, function() return vim.fn['codeium#CycleCompletions'](-1) end,
    { expr = true, silent = true })
set_keymaps("i", { "<C-x>" }, function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
