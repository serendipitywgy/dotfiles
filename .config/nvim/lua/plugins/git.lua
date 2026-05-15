-- 懒加载和配置 gitsigns.nvim
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        vim.cmd.packadd("gitsigns.nvim")
        require("gitsigns").setup({
            signcolumn = false,
            numhl = true,
            current_line_blame = true,
            attach_to_untracked = true,
            preview_config = { border = "rounded" },
            on_attach = function(bufnr)
                local gitsigns = require("gitsigns")
                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end
                -- 按键映射（与原配置一致）
                map("n", "]h",
                    function() if vim.wo.diff then vim.cmd.normal({ "]h", bang = true }) else gitsigns.nav_hunk("next") end end,
                    { desc = "[Git] 下一个块" })
                map("n", "]H",
                    function() if vim.wo.diff then vim.cmd.normal({ "]H", bang = true }) else gitsigns.nav_hunk("last") end end,
                    { desc = "[Git] 最后一个块" })
                map("n", "[h",
                    function() if vim.wo.diff then vim.cmd.normal({ "[h", bang = true }) else gitsigns.nav_hunk("prev") end end,
                    { desc = "[Git] 上一个块" })
                map("n", "[H",
                    function() if vim.wo.diff then vim.cmd.normal({ "[H", bang = true }) else gitsigns.nav_hunk("first") end end,
                    { desc = "[Git] 第一个块" })
                map("n", "<leader>ggs", gitsigns.stage_hunk, { desc = "[Git] 暂存块" })
                map("v", "<leader>ggs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
                    { desc = "[Git] 暂存块 (可视)" })
                map("n", "<leader>ggr", gitsigns.reset_hunk, { desc = "[Git] 重置块" })
                map("v", "<leader>ggr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
                    { desc = "[Git] 重置块 (可视)" })
                map("n", "<leader>ggS", gitsigns.stage_buffer, { desc = "[Git] 暂存缓冲区" })
                map("n", "<leader>ggR", gitsigns.reset_buffer, { desc = "[Git] 重置缓冲区" })
                map("n", "<leader>ggp", gitsigns.preview_hunk, { desc = "[Git] 预览块" })
                map("n", "<leader>ggP", gitsigns.preview_hunk_inline, { desc = "[Git] 内联预览块" })
                map("n", "<leader>ggQ", function() gitsigns.setqflist("all") end,
                    { desc = "[Git] 显示所有差异" })
                map("n", "<leader>ggq", gitsigns.setqflist, { desc = "[Git] 显示差异" })
                map({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "[Git] 当前块" })
                -- snacks 插件相关 toggle
                require("snacks")
                    .toggle({
                        name = "line blame",
                        get = function()
                            return require("gitsigns.config").config.current_line_blame
                        end,
                        set = function(enabled)
                            require("gitsigns").toggle_current_line_blame(enabled)
                        end,
                    })
                    :map("<leader>tgb")
                require("snacks")
                    .toggle({
                        name = "word diff",
                        get = function()
                            return require("gitsigns.config").config.word_diff
                        end,
                        set = function(enabled)
                            require("gitsigns").toggle_word_diff(enabled)
                        end,
                    })
                    :map("<leader>tgw")
            end,
        })
        -- 如需集成 scrollbar，可取消注释
        -- require("scrollbar.handlers.gitsigns").setup()
    end,
})

-- 懒加载和配置 mini.diff
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        vim.cmd.packadd("mini.diff")
        require("mini.diff").setup({
            mappings = {
                apply = "",
                reset = "",
                textobject = "",
                goto_first = "",
                goto_prev = "",
                goto_next = "",
                goto_last = "",
            },
        })
        -- 按键映射
        vim.keymap.set("n", "<leader>to", function()
            require("mini.diff").toggle_overlay(vim.api.nvim_get_current_buf())
        end, { desc = "[Mini.Diff] 切换差异覆盖" })
    end,
})

-- 4. 如需 git-blame.nvim，可按需添加
-- vim.api.nvim_create_autocmd("VeryLazy", {
--   callback = function()
--     vim.cmd.packadd("git-blame.nvim")
--     require("gitblame").setup({
--       enabled = true,
--       message_template = " <summary> • <date> • <author> • <<sha>>",
--       date_format = "%m-%d-%Y %H:%M:%S",
--       virtual_text_column = 1,
--     })
--   end,
-- })
