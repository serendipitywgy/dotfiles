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
                { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
                { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
                { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
                { icon = " ", key = "s", desc = "Sessions", action = ":AutoSession search" },
                { icon = "󰒲 ", key = "u", desc = "Update Plugins", action = ":PackUpdate" },
                { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            },
        },
    },
    explorer = { enabled = false, replace_netrw = true },
    indent = {
        enabled = true,
        animate = {
            enabled = false
        },
        indent = {
            only_scope = true
        },
        scope = {
            enabled = true,   -- enable highlighting the current scope
            underline = true, -- underline the start of the scope
        },
        chunk = {
            -- when enabled, scopes will be rendered as chunks, except for the top-level scope which will be rendered as a scope.
            enabled = true,
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

-- ── Snacks 快捷键 ──────────────────────────────────────────────────────────
local map = vim.keymap.set

-- 通用
map("n", "<leader><space>", function() Snacks.picker.smart() end,            { desc = "Smart Find Files" })
map("n", "<leader>,",       function() Snacks.picker.buffers() end,          { desc = "Buffers" })
map("n", "<leader>/",       function() Snacks.picker.grep() end,             { desc = "Grep" })
map("n", "<leader>:",       function() Snacks.picker.command_history() end,  { desc = "Command History" })

-- find
map("n", "<leader>fb", function() Snacks.picker.buffers() end,                                  { desc = "Buffers" })
map("n", "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find Config File" })
map("n", "<leader>ff", function() Snacks.picker.files() end,                                    { desc = "Find Files" })
map("n", "<leader>fg", function() Snacks.picker.git_files() end,                                { desc = "Find Git Files" })
map("n", "<leader>fp", function() Snacks.picker.projects() end,                                 { desc = "Projects" })
map("n", "<leader>fr", function() Snacks.picker.recent() end,                                   { desc = "Recent" })

-- git
map("n",       "<leader>gb", function() Snacks.picker.git_branches() end, { desc = "Git Branches" })
map("n",       "<leader>gl", function() Snacks.picker.git_log() end,       { desc = "Git Log" })
map("n",       "<leader>gL", function() Snacks.picker.git_log_line() end,  { desc = "Git Log Line" })
map("n",       "<leader>gs", function() Snacks.picker.git_status() end,    { desc = "Git Status" })
map("n",       "<leader>gS", function() Snacks.picker.git_stash() end,     { desc = "Git Stash" })
map("n",       "<leader>gd", function() Snacks.picker.git_diff() end,      { desc = "Git Diff (Hunks)" })
map("n",       "<leader>gf", function() Snacks.picker.git_log_file() end,  { desc = "Git Log File" })
map("n",       "<leader>gg", function() Snacks.lazygit() end,              { desc = "Lazygit" })
map({ "n", "v" }, "<leader>gB", function() Snacks.gitbrowse() end,         { desc = "Git Browse" })

-- grep / search
map("n",       "<leader>sb",   function() Snacks.picker.lines() end,               { desc = "Buffer Lines" })
map("n",       "<leader>sB",   function() Snacks.picker.grep_buffers() end,        { desc = "Grep Open Buffers" })
map("n",       "<leader>sg",   function() Snacks.picker.grep() end,                { desc = "Grep" })
map({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word() end,         { desc = "Visual selection or word" })
map("n",       '<leader>s"',   function() Snacks.picker.registers() end,           { desc = "Registers" })
map("n",       "<leader>s/",   function() Snacks.picker.search_history() end,      { desc = "Search History" })
map("n",       "<leader>sa",   function() Snacks.picker.autocmds() end,            { desc = "Autocmds" })
map("n",       "<leader>sc",   function() Snacks.picker.command_history() end,     { desc = "Command History" })
map("n",       "<leader>sC",   function() Snacks.picker.commands() end,            { desc = "Commands" })
map("n",       "<leader>sd",   function() Snacks.picker.diagnostics() end,         { desc = "Diagnostics" })
map("n",       "<leader>sD",   function() Snacks.picker.diagnostics_buffer() end,  { desc = "Buffer Diagnostics" })
map("n",       "<leader>sh",   function() Snacks.picker.help() end,                { desc = "Help Pages" })
map("n",       "<leader>sH",   function() Snacks.picker.highlights() end,          { desc = "Highlights" })
map("n",       "<leader>si",   function() Snacks.picker.icons() end,               { desc = "Icons" })
map("n",       "<leader>sj",   function() Snacks.picker.jumps() end,               { desc = "Jumps" })
map("n",       "<leader>sk",   function() Snacks.picker.keymaps() end,             { desc = "Keymaps" })
map("n",       "<leader>sl",   function() Snacks.picker.loclist() end,             { desc = "Location List" })
map("n",       "<leader>sm",   function() Snacks.picker.marks() end,               { desc = "Marks" })
map("n",       "<leader>sM",   function() Snacks.picker.man() end,                 { desc = "Man Pages" })
map("n",       "<leader>sp",   function() Snacks.picker.lazy() end,                { desc = "Search for Plugin Spec" })
map("n",       "<leader>sq",   function() Snacks.picker.qflist() end,              { desc = "Quickfix List" })
map("n",       "<leader>sR",   function() Snacks.picker.resume() end,              { desc = "Resume" })
map("n",       "<leader>su",   function() Snacks.picker.undo() end,                { desc = "Undo History" })
map("n",       "<leader>ss",   function() Snacks.picker.lsp_symbols() end,         { desc = "LSP Symbols" })
map("n",       "<leader>sS",   function() Snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols" })

-- LSP 跳转（通过 Snacks picker）
map("n", "gd", function() Snacks.picker.lsp_definitions() end,     { desc = "Goto Definition" })
map("n", "gD", function() Snacks.picker.lsp_declarations() end,    { desc = "Goto Declaration" })
map("n", "gr", function() Snacks.picker.lsp_references() end,      { nowait = true, desc = "References" })
map("n", "gI", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
map("n", "gy", function() Snacks.picker.lsp_type_definitions() end,{ desc = "Goto T[y]pe Definition" })

-- ui
map("n", "<leader>uC", function() Snacks.picker.colorschemes() end, { desc = "Colorschemes" })

-- zen / scratch
map("n", "<leader>z", function() Snacks.zen() end,            { desc = "Toggle Zen Mode" })
map("n", "<leader>Z", function() Snacks.zen.zoom() end,       { desc = "Toggle Zoom" })
map("n", "<leader>.", function() Snacks.scratch() end,        { desc = "Toggle Scratch Buffer" })
map("n", "<leader>S", function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })

-- buffer / file
map("n", "<leader>bd", function() Snacks.bufdelete() end,          { desc = "Delete Buffer" })
map("n", "<leader>cR", function() Snacks.rename.rename_file() end, { desc = "Rename File" })

-- notifications
map("n", "<leader>n",  function() Snacks.notifier.show_history() end, { desc = "Notification History" })
map("n", "<leader>un", function() Snacks.notifier.hide() end,         { desc = "Dismiss All Notifications" })

-- terminal
map({ "n", "i", "t" }, "<c-/>", function() Snacks.terminal() end, { desc = "Toggle Terminal" })
map({ "n", "i", "t" }, "<c-_>", function() Snacks.terminal() end, { desc = "which_key_ignore" })

-- word references jump
map("n", "]]", function() Snacks.words.jump(vim.v.count1) end,  { desc = "Next Reference" })
map("n", "[[", function() Snacks.words.jump(-vim.v.count1) end, { desc = "Prev Reference" })
map("t", "]]", function() Snacks.words.jump(vim.v.count1) end,  { desc = "Next Reference" })
map("t", "[[", function() Snacks.words.jump(-vim.v.count1) end, { desc = "Prev Reference" })
