return {
    "folke/snacks.nvim",
    --event = "VeryLazy",
    lazy = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        -- 确保 pick 模块已加载
        local pick = require("plugins.utils.pick")

        -- 加载 snacks 选择器
        require("plugins.utils.snacks-pick")

        -----------------------
        -- Snacks 核心配置模块 --
        -----------------------
        require("snacks").setup({
            indent = {
                enabled = true,
                animate = {
                    enabled = false
                },
                indent = {
                    only_scope = true
                },
                scope = {
                    enabled = true, -- enable highlighting the current scope
                    underline = true, -- underline the start of the scope
                },
                chunk = {
                    -- when enabled, scopes will be rendered as chunks, except for the top-level scope which will be rendered as a scope.
                    enabled = true,
                },
            },
            zen = {},
            bigfile = {},
            explorer = {
                 enabled = true,
                 replace_netrw = true,
            },
            dashboard = {
                sections = {
                    { section = "header" },
                    {
                        pane = 2,
                        section = "terminal",
                        cmd = "colorscript -e square",
                        height = 5,
                        padding = 1,
                    },
                    { section = "keys",  gap = 1,    padding = 1 },
                    { pane = 2,          icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
                    { pane = 2,          icon = " ", title = "Projects",     section = "projects",     indent = 2, padding = 1 },
                    {
                        pane = 2,
                        icon = " ",
                        title = "Git Status",
                        section = "terminal",
                        enabled = function()
                            return Snacks.git.get_root() ~= nil
                        end,
                        cmd = "git status --short --branch --renames",
                        height = 5,
                        padding = 1,
                        ttl = 5 * 60,
                        indent = 3,
                    },
                    { section = "startup" },
                },
            },
            input = { enabled = true },
            statuscolumn = { enabled = true },
            terminal = { enabled = true },
            lazygit = {
                enabled = false,
                configure = false,
            },
            notifier = {
                enabled = true,
                style = "notifications",
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
                },
            },
            words = { enabled = true },
            quickfile = { enabled = true },
            scroll = { enabled = false },
            -- Create keymappings of `ii` and `ai` for textobjects, and `[i` and `]i` for jumps
            -- 快捷键vii，vai
            scope = {
                enabled = true,
                cursor = false,
            },
            picker = {
                win = {
                    input = {
                        keys = {
                            ["<a-c>"] = {
                                "toggle_cwd",
                                mode = { "n", "i" },
                            },
                        },
                    },
                },
                actions = {
                    ---@param p snacks.Picker
                    toggle_cwd = function(p)
                        local root = Root({ buf = p.input.filter.current_buf, normalize = true })
                        local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
                        local current = p:cwd()
                        p:set_cwd(current == root and cwd or root)
                        p:find()
                    end,
                },
                sources = {
                    explorer = {
                        -- your explorer picker configuration comes here
                        -- or leave it empty to use the default settings
                    }
                }
            },
        })

        -- 设置快捷键
        local keymap = vim.keymap.set

        -- 基础快捷键
        keymap("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "[Snacks] Buffers" })
        keymap("n", "<leader>/", pick("grep"), { desc = "Grep (Root Dir)" })
        keymap("n", "<leader>:", function() Snacks.picker.command_history() end, { desc = "[Snacks] Command History" })
        -- keymap("n", "<leader><space>", pick("files"), { desc = "Find Files (Root Dir)" })
        keymap("n", "<leader><space>", function() Snacks.picker.files() end, { desc = "[Snacks] Find Files (Root Dir)" })
        keymap("n", "<leader>n", function() Snacks.picker.notifications() end, { desc = "[Snacks] Notification History" })

        -- buffer相关
        keymap("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "[Snacks] Delete Buffer" })
        keymap("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "[Snacks] Delete Other Buffer" })

        -- Notification
        keymap("n", "<leader>sn", function() require("snacks").picker.notifications() end, {desc = "[Snacks] Notification history"})
        keymap("n", "<leader>n", function() require("snacks").notifier.show_history() end, {desc = "[Snacks] Notification history"})
        keymap("n", "<leader>un", function() require("snacks").notifier.hide() end, {desc = "[Snacks] Dismiss all notifications"})

        -- 查找文件相关
        keymap("n", "<leader>sb", function() Snacks.picker.buffers() end, { desc = "[Snacks] Buffers" })
        keymap("n", "<leader>sB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end,{ desc = "[Snacks] Buffers (all)" })
        keymap("n", "<leader>fc", pick.config_files(), { desc = "[pick] Find Config File" })
        keymap("n", "<leader>sf", function () Snacks.picker.files() end, { desc = "[Snacks] Find Files (Root Dir)" })
        keymap("n", "<leader>sF", function () Snacks.picker.files({ root = false }) end, { desc = "[Snacks] Find Files (cwd)" })
        keymap("n", "<leader>sr", function() Snacks.picker.recent({ filter = { cwd = true } }) end,{ desc = "[Snacks] Recent (cwd)" })
        keymap("n", "<leader>sg", function() Snacks.picker.git_files() end, { desc = "[Snacks] Find Files (git-files)" })
        keymap("n", "<leader>sp", function() Snacks.picker.projects() end, { desc = "[Snacks] Projects" })

        -- Git 相关
        keymap("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "[Snacks] Git Diff (hunks)" })
        keymap("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "[Snacks] Git Status" })
        keymap("n", "<leader>gS", function() Snacks.picker.git_stash() end, { desc = "[Snacks] Git Stash" })
        -- lazygit
        if vim.fn.executable("lazygit") == 1 then
          keymap("n", "<leader>gg", function() Snacks.lazygit({cwd = Root.git()}) end, { desc = "[Snacks] Lazygit (Root Dir)" })
          keymap("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "[Snacks] Lazygit (cwd)" })
          keymap("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "[Snacks] Git Current File History" })
          keymap("n", "<leader>gl", function() Snacks.picker.git_log({ cwd = _G.Root.git() }) end, { desc = "[Snacks] Git Log" })
          keymap("n", "<leader>gL", function() Snacks.picker.git_log() end, { desc = "[Snacks] Git Log (cwd)" })
        end

        keymap("n", "<leader>gb", function() Snacks.picker.git_log_line() end, { desc = "[Snacks] Git Blame Line" })
        keymap({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "[Snacks] Git Browse (open)" })
        keymap({"n", "x" }, "<leader>gY", function() Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false }) end, { desc = "[Snacks] Git Browse (copy)" })


        -- 搜索相关
        keymap("n", "<leader>sb", function() Snacks.picker.lines() end, { desc = "[Snacks] Buffer Lines" })
        keymap("n", "<leader>sB", function() Snacks.picker.grep_buffers() end, { desc = "[Snacks] Grep Open Buffers" })
        keymap("n", "<leader>sg", pick("live_grep"), { desc = "[pick] Grep (Root Dir)" })
        keymap("n", "<leader>sG", pick("live_grep", { root = false }), { desc = "[pick] Grep (cwd)" })
        keymap({ "n", "x" }, "<leader>sw", pick("grep_word"), { desc = "[Snacks] Visual selection or word (Root Dir)" })
        keymap({ "n", "x" }, "<leader>sW", pick("grep_word", { root = false }),{ desc = "[Snacks] Visual selection or word (cwd)" })

        -- 更多搜索功能
        keymap("n", '<leader>s"', function() Snacks.picker.registers() end, { desc = "[Snacks] Registers" })
        keymap("n", '<leader>s/', function() Snacks.picker.search_history() end, { desc = "[Snacks] Search History" })
        keymap("n", "<leader>sa", function() Snacks.picker.autocmds() end, { desc = "[Snacks] Autocmds" })
        keymap("n", "<leader>sc", function() Snacks.picker.command_history() end, { desc = "[Snacks] Command History" })
        keymap("n", "<leader>sC", function() Snacks.picker.commands() end, { desc = "[Snacks] Commands" })
        keymap("n", "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "[Snacks] Diagnostics" })
        keymap("n", "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, { desc = "[Snacks] Buffer Diagnostics" })
        keymap("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "[Snacks] Help Pages" })
        keymap("n", "<leader>sH", function() Snacks.picker.highlights() end, { desc = "[Snacks] Highlights" })
        keymap("n", "<leader>si", function() Snacks.picker.icons() end, { desc = "[Snacks] Icons" })
        keymap("n", "<leader>sj", function() Snacks.picker.jumps() end, { desc = "[Snacks] Jumps" })
        keymap("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "[Snacks] Keymas" })
        keymap("n", "<leader>sl", function() Snacks.picker.loclist() end, { desc = "[Snacks] Location List" })
        keymap("n", "<leader>sM", function() Snacks.picker.man() end, { desc = "[Snacks] Man Pages" })
        keymap("n", "<leader>sm", function() Snacks.picker.marks() end, { desc = "[Snacks] Marks" })
        keymap("n", "<leader>sR", function() Snacks.picker.resume() end, { desc = "[Snacks] Resume" })
        keymap("n", "<leader>sq", function() Snacks.picker.qflist() end, { desc = "[Snacks] Quickfix List" })
        keymap("n", "<leader>su", function() Snacks.picker.undo() end, { desc = "[Snacks] Undotree" })
    -- floating terminal
        keymap("n", "<leader>fT", function() Snacks.terminal() end, { desc = "[Snacks] Terminal (cwd)" })
        keymap("n", "<leader>ft", function() Snacks.terminal(nil, { cwd = _G.Root.get() }) end, { desc = "[Snacks] Terminal (Root Dir)" })
        keymap("n", "<c-/>",      function() Snacks.terminal(nil, { cwd = _G.Root.get() }) end, { desc = "[Snacks] Terminal (Root Dir)" })
        keymap("n", "<c-_>",      function() Snacks.terminal(nil, { cwd = _G.Root.get() }) end, { desc = "which_key_ignore" })

        -- UI 相关
        keymap("n", "<leader>uC", function() Snacks.picker.colorschemes() end, { desc = "[Snacks] Colorschemes" })

        keymap("n", "<leader>e", function() 
		-- 使用你自定义的 Root 模块获取项目根目录
		local root = _G.Root()
		Snacks.explorer.open({ cwd = root })
        end, { desc = "[Snacks] Explorer (Root Dir)" })

        keymap("n", "<leader>E", function() 
		-- 获取当前文件所在目录
		local buf = vim.api.nvim_get_current_buf()
		local file = vim.api.nvim_buf_get_name(buf)
		local dir = file ~= "" and vim.fn.fnamemodify(file, ":h") or vim.fn.getcwd()

		-- 打开文件浏览器并定位到当前文件
		Snacks.explorer.open({
			cwd = dir,
			reveal = file ~= "",
		})
        end, { desc = "[Snacks] Explorer (Current File Dir)" })
        -- 进入 Zen 模式
        keymap("n", "<leader>z", function() Snacks.zen.zen() end, { desc = "[Snacks] Toggle Zen Mode" })
        -- 进入 Zoom 模式（最大化当前窗口）
        keymap("n", "<leader>Z", function() Snacks.zen.zoom() end, { desc = "[Snacks] Toggle Zoom Mode" })

        keymap("n", "<leader>ti", function()
		if Snacks.indent.enabled then
			Snacks.indent.disable()
		else
			Snacks.indent.enable()
		end
        end,{ desc = "[Snacks] enable/disable indent" })


        -- LSP 相关快捷键
        if vim.lsp.handlers then
            keymap("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "[Snacks] Goto Definition" })
            keymap("n", "gr", function() Snacks.picker.lsp_references() end, { desc = "[Snacks] References", nowait = true })
            keymap("n", "gI", function() Snacks.picker.lsp_implementations() end, { desc = "[Snacks] Goto Implementation" })
            keymap("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "[Snacks] Goto T[y]pe Definition" })
            keymap("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "[Snacks] LSP Symbols" })
            keymap("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end,
                { desc = "[Snacks] LSP Workspace Symbols" })
        end

        -- 如果安装了 todo-comments 插件
        if package.loaded["todo-comments"] then
            keymap("n", "<leader>st", function() Snacks.picker.todo_comments() end, { desc = "Todo" })
            keymap("n", "<leader>sT",
                function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end,
                { desc = "Todo/Fix/Fixme" })
        end

        -- 如果安装了 flash.nvim 插件
        if package.loaded["flash"] then
            local current_opts = require("snacks").config.picker or {}
            local new_opts = vim.tbl_deep_extend("force", current_opts, {
                win = {
                    input = {
                        keys = {
                            ["<a-s>"] = { "flash", mode = { "n", "i" } },
                            ["s"] = { "flash" },
                        },
                    },
                },
                actions = {
                    flash = function(picker)
                        require("flash").jump({
                            pattern = "^",
                            label = { after = { 0, 0 } },
                            search = {
                                mode = "search",
                                exclude = {
                                    function(win)
                                        return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                                    end,
                                },
                            },
                            action = function(match)
                                local idx = picker.list:row2idx(match.pos[1])
                                picker.list:_move(idx, true, true)
                            end,
                        })
                    end,
                },
            })
            require("snacks").setup({ picker = new_opts })
        end

        -- 如果安装了 trouble.nvim 插件
        if package.loaded["trouble"] then
            local current_opts = require("snacks").config.picker or {}
            local new_opts = vim.tbl_deep_extend("force", current_opts, {
                actions = {
                    trouble_open = function(...)
                        return require("trouble.sources.snacks").actions.trouble_open.action(...)
                    end,
                },
                win = {
                    input = {
                        keys = {
                            ["<a-t>"] = {
                                "trouble_open",
                                mode = { "n", "i" },
                            },
                        },
                    },
                },
            })
            require("snacks").setup({ picker = new_opts })
        end
    end,
}
