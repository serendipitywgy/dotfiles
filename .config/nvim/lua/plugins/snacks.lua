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
