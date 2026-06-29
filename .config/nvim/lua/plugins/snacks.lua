-- Picker
require("snacks").setup({
    bigfile = { enabled = true },
    zen = { enabled = true },
    dashboard = {
        sections = {
            -- 左栏：logo + 快捷键
            {
                pane = 1,
                section = "header",
            },
            {
                pane = 1,
                section = "keys",
                gap = 1,
                padding = 1,
            },
            -- 右栏：git log
            {
                pane = 2,
                icon = " ",
                title = "Git Log",
                section = "terminal",
                cmd = "git log --oneline --graph --color=always -10 2>/dev/null || echo '  (no git repo)'",
                height = 10,
                padding = 1,
                ttl = 60,
                indent = 2,
            },
            -- 右栏：项目列表
            {
                pane = 2,
                icon = " ",
                title = "Projects",
                section = "projects",
                indent = 2,
                padding = 1,
                limit = 5,
                session = false,
                dirs = function()
                    local sessions_dir = vim.fn.stdpath("data") .. "/sessions"
                    local dirs = {}
                    local seen = {}
                    local files = vim.fn.glob(sessions_dir .. "/*.vim", false, true)
                    table.sort(files, function(a, b)
                        return vim.fn.getftime(a) > vim.fn.getftime(b)
                    end)
                    for _, f in ipairs(files) do
                        local name = vim.fn.fnamemodify(f, ":t:r")
                        -- percent decode
                        local decoded = name:gsub("%%(%x%x)", function(h)
                            return string.char(tonumber(h, 16))
                        end)
                        -- strip branch suffix (|branch-name)
                        local dir = decoded:match("^([^|]+)") or decoded
                        if not seen[dir] and vim.fn.isdirectory(dir) == 1 then
                            seen[dir] = true
                            table.insert(dirs, dir)
                        end
                    end
                    return dirs
                end,
                action = function(dir)
                    vim.fn.chdir(dir)
                    local ok, auto_session = pcall(require, "auto-session")
                    if ok and auto_session.session_exists_for_cwd() then
                        auto_session.restore_session()
                    else
                        Snacks.picker.files({ cwd = dir })
                    end
                end,
            },
            -- 右栏：最近文件
            {
                pane = 2,
                icon = " ",
                title = "Recent Files",
                section = "recent_files",
                indent = 2,
                padding = 1,
                limit = 5,
            },
        },

        -- "                                   ",
        -- "         ║    ║    ║               ",
        -- "         ║    ║    ║               ",
        -- "    ══════╩════╩════╩══════         ",
        -- "         ╔══════════╗              ",
        -- "         ║          ║              ",
        -- "         ╠══════════╣              ",
        -- "         ║          ║              ",
        -- "         ╚══════════╝              ",
        -- "           ╲      ╱                ",
        -- "            ╲    ╱                 ",
        -- "                                   ",
        -- "        「 覔 · 寻觅 」             ",
        -- "                                   ",
        preset = {
            header = table.concat({
                "                                   ",
                "         ║    ║    ║               ",
                "         ║    ║    ║               ",
                "    ══════╩════╩════╩══════         ",
                "         ╔══════════╗              ",
                "         ║          ║              ",
                "         ╠══════════╣              ",
                "         ║          ║              ",
                "         ╚══════════╝              ",
                "           ╲      ╱                ",
                "            ╲    ╱                 ",
                "                                   ",
                "        「 古法编程 」             ",
                "                                   ",
            }, "\n"),
            keys = {
                { icon = " ", key = "f", desc = "查找文件", action = ":lua Snacks.picker.files()" },
                { icon = " ", key = "n", desc = "新建文件", action = ":ene | startinsert" },
                { icon = " ", key = "r", desc = "最近文件", action = ":lua Snacks.picker.recent()" },
                { icon = " ", key = "g", desc = "查找文本", action = ":lua Snacks.picker.grep()" },
                { icon = " ", key = "s", desc = "会话", action = ":AutoSession search" },
                { icon = "󰒲 ", key = "u", desc = "更新插件", action = ":PackUpdate" },
                { icon = " ", key = "q", desc = "退出", action = ":qa" },
            },
        },
    },
    explorer = { enabled = true, replace_netrw = false, hidden = true },
    image = { enabled = true },
    dim = { enabled = false },
    indent = {
        enabled = true,
        animate = {
            enabled = false,
        },
        indent = {
            only_scope = true,
            only_current = true,
            hl = { "SnacksIndent1", "SnacksIndent2", "SnacksIndent3", "SnacksIndent4",
                   "SnacksIndent5", "SnacksIndent6", "SnacksIndent7", "SnacksIndent8" },
        },
        scope = {
            enabled = true,
            underline = true,
            only_current = true,
        },
        chunk = {
            enabled = true,
            char = { corner_top = "╭", corner_bottom = "╰", arrow = ">" },
        },
    },
    input = { enabled = true },
    notifier = {
        enabled = true,
        timeout = 3000,
        style = "notification",
    },
    picker = {
        enabled = true,
        layout = "ivy",
        -- layout = "telescope",
        sources = {
            explorer = { layout = "sidebar" },
            grep = { exclude = { "node_modules/*", "dist/*", "build/*", ".git/*", "__pycache__/*", "*.min.*", "*.map" } },
        },
        win = {
            input = {
                keys = {
                    -- 将搜索结果打开到 buffer（grep 结果用）
                    ["<c-e>"] = { "open_results_in_buffer", mode = { "n", "i" } },
                    -- 在 buffer 列表中删除选中（或当前）buffer，支持 Tab 多选后批量删除
                    ["<c-d>"] = { "delete_buffers", mode = { "n", "i" } },
                },
            },
        },
        actions = {
            open_results_in_buffer = function(picker)
                picker:close()
                local items = picker:selected()
                if #items == 0 then
                    items = picker:items()
                end
                require("config.utils").open_grep_results(items)
            end,
            -- 批量删除 buffer：Tab 多选后 <C-d> 一次性关闭，无多选则只关闭当前条目
            delete_buffers = function(picker)
                local items = picker:selected()
                if #items == 0 then
                    items = { picker:current() }
                end
                for _, item in ipairs(items) do
                    Snacks.bufdelete(item.buf)
                end
                picker:find()
            end,
        },
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    toggle = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    lazygit = {
        enabled = false,
        configure = false,
    },
    styles = {
        terminal = {
            relative = "editor",
            border = "rounded",
            position = "float",
            backdrop = 60,
            height = 0.9,
            width = 0.9,
            zindex = 50,
        }
    },
})

-- Snacks.dim.enable()

-- ── Snacks 快捷键 ──────────────────────────────────────────────────────────
local map = vim.keymap.set

-- 通用
map("n", "<leader>e", function() Snacks.explorer.open() end, { desc = "文件浏览器" })
map("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "智能查找文件" })
map("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "缓冲区列表" })
map("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "搜索" })
map("n", "<leader>:", function() Snacks.picker.command_history() end, { desc = "命令历史" })

-- find
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "缓冲区列表" })
map("n", "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "查找配置文件" })
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "查找文件" })
map("n", "<leader>fg", function() Snacks.picker.git_files() end, { desc = "查找 Git 文件" })
map("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "项目列表" })
map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "最近文件" })

-- git
map("n", "<leader>gb", function() Snacks.picker.git_branches() end, { desc = "Git 分支" })
map("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git 日志" })
map("n", "<leader>gL", function() Snacks.picker.git_log_line() end, { desc = "Git 行日志" })
map("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git 状态" })
map("n", "<leader>gS", function() Snacks.picker.git_stash() end, { desc = "Git 暂存" })
map("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "Git 差异" })
map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git 文件日志" })
map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
map({ "n", "v" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git 浏览" })

-- grep / search
map("n", "<leader>sb", function() Snacks.picker.lines() end, { desc = "缓冲区行" })
map("n", "<leader>sB", function() Snacks.picker.grep_buffers() end, { desc = "搜索打开的缓冲区" })
map("n", "<leader>sg", function() Snacks.picker.grep() end, { desc = "搜索" })
map({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word() end, { desc = "可视选择或单词" })
map("n", '<leader>s"', function() Snacks.picker.registers() end, { desc = "寄存器" })
map("n", "<leader>s/", function() Snacks.picker.search_history() end, { desc = "搜索历史" })
map("n", "<leader>sa", function() Snacks.picker.autocmds() end, { desc = "自动命令" })
map("n", "<leader>sc", function() Snacks.picker.command_history() end, { desc = "命令历史" })
map("n", "<leader>sC", function() Snacks.picker.commands() end, { desc = "命令列表" })
map("n", "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "诊断信息" })
map("n", "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, { desc = "缓冲区诊断" })
map("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "帮助页面" })
map("n", "<leader>sH", function() Snacks.picker.highlights() end, { desc = "高亮组" })
map("n", "<leader>si", function() Snacks.picker.icons() end, { desc = "图标" })
map("n", "<leader>sj", function() Snacks.picker.jumps() end, { desc = "跳转列表" })
map("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "快捷键" })
map("n", "<leader>sl", function() Snacks.picker.loclist() end, { desc = "位置列表" })
map("n", "<leader>sm", function() Snacks.picker.marks() end, { desc = "标记" })
map("n", "<leader>sM", function() Snacks.picker.man() end, { desc = "手册页" })
map("n", "<leader>sq", function() Snacks.picker.qflist() end, { desc = "Quickfix 列表" })
map("n", "<leader>sR", function() Snacks.picker.resume() end, { desc = "恢复" })
map("n", "<leader>su", function() Snacks.picker.undo() end, { desc = "撤销历史" })
map("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "LSP 符号" })
map("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "LSP 工作区符号" })

-- LSP 跳转（通过 Snacks picker）
-- map("n", "gd", function() Snacks.picker.lsp_definitions() end,     { desc = "跳转到定义" })
-- lsp.lua已经有gd跳转定义的快捷键, 这里屏蔽
-- map("n", "gD", function() Snacks.picker.lsp_declarations() end,    { desc = "跳转到声明" })
-- lsp.lua已经有gD跳转声明的快捷键, 这里屏蔽

map("n", "gr", function() Snacks.picker.lsp_references() end, { nowait = true, desc = "引用" })
map("n", "gI", function() Snacks.picker.lsp_implementations() end, { desc = "跳转到实现" })
map("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "跳转到类型定义" })

-- ui
map("n", "<leader>uC", function()
    local builtin = {
        "blue", "darkblue", "default", "delek", "desert", "elflord", "evening",
        "habamax", "industry", "koehler", "lunaperche", "morning", "murphy",
        "pablo", "peachpuff", "quiet", "retrobox", "ron", "shine", "slate",
        "sorbet", "torte", "vim", "wildcharm", "zaibatsu", "zellner",
    }
    local set = {}
    for _, name in ipairs(builtin) do set[name] = true end
    Snacks.picker.colorschemes({
        transform = function(item)
            return not set[item.text]
        end,
    })
end, { desc = "配色方案" })

-- zen / scratch
map("n", "<leader>z", function() Snacks.zen() end, { desc = "切换禅定模式" })
map("n", "<leader>Z", function() Snacks.zen.zoom() end, { desc = "切换缩放" })
map("n", "<leader>.", function() Snacks.scratch() end, { desc = "切换临时缓冲区" })
map("n", "<leader>S", function() Snacks.scratch.select() end, { desc = "选择临时缓冲区" })

-- buffer / file
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "删除缓冲区" })
map("n", "<leader>cR", function() Snacks.rename.rename_file() end, { desc = "重命名文件" })

-- notifications
map("n", "<leader>n", function() Snacks.notifier.show_history() end, { desc = "通知历史" })
map("n", "<leader>un", function() Snacks.notifier.hide() end, { desc = "关闭所有通知" })

-- terminal
map({ "n", "i", "t" }, "<c-/>", function() Snacks.terminal() end, { desc = "切换终端" })
map({ "n", "i", "t" }, "<c-_>", function() Snacks.terminal() end, { desc = "which_key_ignore" })

-- word references jump
map("n", "]]", function() Snacks.words.jump(vim.v.count1) end, { desc = "下一个引用" })
map("n", "[[", function() Snacks.words.jump(-vim.v.count1) end, { desc = "上一个引用" })
map("t", "]]", function() Snacks.words.jump(vim.v.count1) end, { desc = "下一个引用" })
map("t", "[[", function() Snacks.words.jump(-vim.v.count1) end, { desc = "上一个引用" })
