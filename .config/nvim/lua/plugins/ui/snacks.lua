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
                indent = {
                    priority = 1,
                    enabled = true,           -- 启用缩进指南
                    char = "│",               -- 缩进指南使用的字符
                    only_scope = false,       -- 是否只显示作用域的缩进指南
                    only_current = false,     -- 是否只在当前窗口显示缩进指南
                    -- hl = "SnacksIndent",      -- 缩进指南的高亮组
                    -- 可以使用多个高亮组循环显示不同级别的缩进
                    hl = {
                        "SnacksIndent1",
                        "SnacksIndent2",
                        "SnacksIndent3",
                        "SnacksIndent4",
                        "SnacksIndent5",
                        "SnacksIndent6",
                        "SnacksIndent7",
                        "SnacksIndent8",
                    },
                },
            },
            zen = {
            },
            explorer = {
                 enabled = true,
                 replace_netrw = true,
            },
            dashboard = {
                preset = {
                    header = [[
██╗    ██╗ █████╗ ███╗   ██╗ ██████╗     ██████╗ ██╗   ██╗
██║    ██║██╔══██╗████╗  ██║██╔════╝    ██╔════╝ ╚██╗ ██╔╝
██║ █╗ ██║███████║██╔██╗ ██║██║  ███╗   ██║  ███╗ ╚████╔╝ 
██║███╗██║██╔══██║██║╚██╗██║██║   ██║   ██║   ██║  ╚██╔╝  
╚███╔███╔╝██║  ██║██║ ╚████║╚██████╔╝   ╚██████╔╝   ██║   
 ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═════╝    ╚═╝   ]],
                },
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
            notifier = {},
            words = {},
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
        keymap("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "Buffers" })
        keymap("n", "<leader>/", pick("grep"), { desc = "Grep (Root Dir)" })
        keymap("n", "<leader>:", function() Snacks.picker.command_history() end, { desc = "Command History" })
        keymap("n", "<leader><space>", pick("files"), { desc = "Find Files (Root Dir)" })
        keymap("n", "<leader>n", function() Snacks.picker.notifications() end, { desc = "Notification History" })

        -- 查找文件相关
        keymap("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
        keymap("n", "<leader>fB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end,
            { desc = "Buffers (all)" })
        keymap("n", "<leader>fc", pick.config_files(), { desc = "Find Config File" })
        keymap("n", "<leader>ff", pick("files"), { desc = "Find Files (Root Dir)" })
        keymap("n", "<leader>fF", pick("files", { root = false }), { desc = "Find Files (cwd)" })
        keymap("n", "<leader>fg", function() Snacks.picker.git_files() end, { desc = "Find Files (git-files)" })
        keymap("n", "<leader>fr", pick("oldfiles"), { desc = "Recent" })
        keymap("n", "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true } }) end,
            { desc = "Recent (cwd)" })
        keymap("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "Projects" })

        -- Git 相关
        keymap("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "Git Diff (hunks)" })
        keymap("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git Status" })
        keymap("n", "<leader>gS", function() Snacks.picker.git_stash() end, { desc = "Git Stash" })

        -- 搜索相关
        keymap("n", "<leader>sb", function() Snacks.picker.lines() end, { desc = "Buffer Lines" })
        keymap("n", "<leader>sB", function() Snacks.picker.grep_buffers() end, { desc = "Grep Open Buffers" })
        keymap("n", "<leader>sg", pick("live_grep"), { desc = "Grep (Root Dir)" })
        keymap("n", "<leader>sG", pick("live_grep", { root = false }), { desc = "Grep (cwd)" })
        keymap({ "n", "x" }, "<leader>sw", pick("grep_word"), { desc = "Visual selection or word (Root Dir)" })
        keymap({ "n", "x" }, "<leader>sW", pick("grep_word", { root = false }),
            { desc = "Visual selection or word (cwd)" })

        -- 更多搜索功能
        keymap("n", '<leader>s"', function() Snacks.picker.registers() end, { desc = "Registers" })
        keymap("n", '<leader>s/', function() Snacks.picker.search_history() end, { desc = "Search History" })
        keymap("n", "<leader>sa", function() Snacks.picker.autocmds() end, { desc = "Autocmds" })
        keymap("n", "<leader>sc", function() Snacks.picker.command_history() end, { desc = "Command History" })
        keymap("n", "<leader>sC", function() Snacks.picker.commands() end, { desc = "Commands" })
        keymap("n", "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
        keymap("n", "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
        keymap("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Help Pages" })
        keymap("n", "<leader>sH", function() Snacks.picker.highlights() end, { desc = "Highlights" })
        keymap("n", "<leader>si", function() Snacks.picker.icons() end, { desc = "Icons" })
        keymap("n", "<leader>sj", function() Snacks.picker.jumps() end, { desc = "Jumps" })
        keymap("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
        keymap("n", "<leader>sl", function() Snacks.picker.loclist() end, { desc = "Location List" })
        keymap("n", "<leader>sM", function() Snacks.picker.man() end, { desc = "Man Pages" })
        keymap("n", "<leader>sm", function() Snacks.picker.marks() end, { desc = "Marks" })
        keymap("n", "<leader>sR", function() Snacks.picker.resume() end, { desc = "Resume" })
        keymap("n", "<leader>sq", function() Snacks.picker.qflist() end, { desc = "Quickfix List" })
        keymap("n", "<leader>su", function() Snacks.picker.undo() end, { desc = "Undotree" })

        -- UI 相关
        keymap("n", "<leader>uC", function() Snacks.picker.colorschemes() end, { desc = "Colorschemes" })

        keymap("n", "<leader>e", function() 
		-- 使用你自定义的 Root 模块获取项目根目录
		local root = Root()
		Snacks.explorer.open({ cwd = root })
        end, { desc = "Explorer (Root Dir)" })

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
        end, { desc = "Explorer (Current File Dir)" })
        -- 进入 Zen 模式
        keymap("n", "<leader>z", function() Snacks.zen.zen() end, { desc = "Toggle Zen Mode" })
        -- 进入 Zoom 模式（最大化当前窗口）
        keymap("n", "<leader>Z", function() Snacks.zen.zoom() end, { desc = "Toggle Zoom Mode" })

        keymap("n", "<leader>ti", function()
		if Snacks.indent.enabled then
			Snacks.indent.disable()
		else
			Snacks.indent.enable()
		end
        end,{ desc = "enable/disable indent" })


        -- LSP 相关快捷键
        if vim.lsp.handlers then
            keymap("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
            keymap("n", "gr", function() Snacks.picker.lsp_references() end, { desc = "References", nowait = true })
            keymap("n", "gI", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
            keymap("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto T[y]pe Definition" })
            keymap("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
            keymap("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end,
                { desc = "LSP Workspace Symbols" })
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
