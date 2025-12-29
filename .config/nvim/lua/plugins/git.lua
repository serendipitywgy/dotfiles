vim.pack.add({
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/echasnovski/mini.diff",  version = vim.version.range("*") },
    -- 如需 git-blame.nvim，可取消注释
    -- { src = "https://github.com/f-person/git-blame.nvim" },
})

-- 2. 懒加载和配置 gitsigns.nvim
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
                    { desc = "[Git] Next hunk" })
                map("n", "]H",
                    function() if vim.wo.diff then vim.cmd.normal({ "]H", bang = true }) else gitsigns.nav_hunk("last") end end,
                    { desc = "[Git] Last hunk" })
                map("n", "[h",
                    function() if vim.wo.diff then vim.cmd.normal({ "[h", bang = true }) else gitsigns.nav_hunk("prev") end end,
                    { desc = "[Git] Prev hunk" })
                map("n", "[H",
                    function() if vim.wo.diff then vim.cmd.normal({ "[H", bang = true }) else gitsigns.nav_hunk("first") end end,
                    { desc = "[Git] First hunk" })
                map("n", "<leader>ggs", gitsigns.stage_hunk, { desc = "[Git] Stage hunk" })
                map("v", "<leader>ggs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
                    { desc = "[Git] Stage hunk (Visual)" })
                map("n", "<leader>ggr", gitsigns.reset_hunk, { desc = "[Git] Reset hunk" })
                map("v", "<leader>ggr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
                    { desc = "[Git] Reset hunk (Visual)" })
                map("n", "<leader>ggS", gitsigns.stage_buffer, { desc = "[Git] Stage buffer" })
                map("n", "<leader>ggR", gitsigns.reset_buffer, { desc = "[Git] Reset buffer" })
                map("n", "<leader>ggp", gitsigns.preview_hunk, { desc = "[Git] Preview hunk" })
                map("n", "<leader>ggP", gitsigns.preview_hunk_inline, { desc = "[Git] Preview hunk inline" })
                map("n", "<leader>ggQ", function() gitsigns.setqflist("all") end,
                    { desc = "[Git] Show diffs (ALL) in qflist" })
                map("n", "<leader>ggq", gitsigns.setqflist, { desc = "[Git] Show diffs in qflist" })
                map({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "[Git] Current hunk" })
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

-- 3. 懒加载和配置 mini.diff
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
        end, { desc = "[Mini.Diff] Toggle diff overlay" })
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
