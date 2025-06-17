return {
    {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPost",
        opts = {
            signcolumn = false,
            numhl = true,
            -- word_diff = true,
            current_line_blame = true,
            attach_to_untracked = true,
            preview_config = {
                border = "rounded",
            },
            on_attach = function(bufnr)
                local gitsigns = require("gitsigns")

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                -- stylua: ignore
                map("n", "]h",
                    function() if vim.wo.diff then vim.cmd.normal({ "]h", bang = true }) else gitsigns.nav_hunk("next") end end,
                    { desc = "[Git] Next hunk" })
                -- stylua: ignore
                map("n", "]H",
                    function() if vim.wo.diff then vim.cmd.normal({ "]H", bang = true }) else gitsigns.nav_hunk("last") end end,
                    { desc = "[Git] Last hunk" })
                -- stylua: ignore
                map("n", "[h",
                    function() if vim.wo.diff then vim.cmd.normal({ "[h", bang = true }) else gitsigns.nav_hunk("prev") end end,
                    { desc = "[Git] Prev hunk" })
                -- stylua: ignore
                map("n", "[H",
                    function() if vim.wo.diff then vim.cmd.normal({ "[H", bang = true }) else gitsigns.nav_hunk("first") end end,
                    { desc = "[Git] First hunk" })

                -- Actions
                map("n", "<leader>ggs", gitsigns.stage_hunk, { desc = "[Git] Stage hunk" })
                -- stylua: ignore
                map("v", "<leader>ggs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
                    { desc = "[Git] Stage hunk (Visual)" })

                map("n", "<leader>ggr", gitsigns.reset_hunk, { desc = "[Git] Reset hunk" })
                -- stylua: ignore
                map("v", "<leader>ggr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
                    { desc = "[Git] Reset hunk (Visual)" })

                map("n", "<leader>ggS", gitsigns.stage_buffer, { desc = "[Git] Stage buffer" })
                map("n", "<leader>ggR", gitsigns.reset_buffer, { desc = "[Git] Reset buffer" })

                map("n", "<leader>ggp", gitsigns.preview_hunk, { desc = "[Git] Preview hunk" })
                map("n", "<leader>ggP", gitsigns.preview_hunk_inline, { desc = "[Git] Preview hunk inline" })

                -- map("n", "<leader>ggb", function() gitsigns.blame_line({ full = true }) end, { desc = "[Git] Blame line" })

                -- stylua: ignore
                -- map("n", "<leader>ggd", gitsigns.diffthis, { desc = "[Git] diff" })
                -- stylua: ignore
                -- map("n", "<leader>ggD", function() gitsigns.diffthis("~") end, { desc = "[Git] diff (ALL)" })

                -- stylua: ignore
                map("n", "<leader>ggQ", function() gitsigns.setqflist("all") end,
                    { desc = "[Git] Show diffs (ALL) in qflist" })
                -- stylua: ignore
                map("n", "<leader>ggq", gitsigns.setqflist, { desc = "[Git] Show diffs in qflist" })

                -- Text object
                map({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "[Git] Current hunk" })

                -- Toggles
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
        },
        config = function(_, opts)
            require("gitsigns").setup(opts)
            -- require("scrollbar.handlers.gitsigns").setup()
        end,
    },

    {
        "echasnovski/mini.diff",
        event = "BufReadPost",
        version = "*",
        -- stylua: ignore
        keys = {
            { "<leader>to", function() require("mini.diff").toggle_overlay(vim.api.nvim_get_current_buf()) end, mode = "n", desc = "[Mini.Diff] Toggle diff overlay", },
        },
        opts = {
            -- Module mappings. Use `''` (empty string) to disable one.
            -- NOTE: Mappings are handled by gitsigns.
            mappings = {
                -- Apply hunks inside a visual/operator region
                apply = "",
                -- Reset hunks inside a visual/operator region
                reset = "",
                -- Hunk range textobject to be used inside operator
                -- Works also in Visual mode if mapping differs from apply and reset
                textobject = "",
                -- Go to hunk range in corresponding direction
                goto_first = "",
                goto_prev = "",
                goto_next = "",
                goto_last = "",
            },
        },
    },
    -- {
    --     "f-person/git-blame.nvim",
    --     event = "VeryLazy",
    --     -- Because of the keys part, you will be lazy loading this plugin.
    --     -- The plugin will only load once one of the keys is used.
    --     -- If you want to load the plugin at startup, add something like event = "VeryLazy",
    --     -- or lazy = false. One of both options will work.
    --     opts = {
    --         -- your configuration comes here
    --         -- for example
    --         enabled = true, -- if you want to enable the plugin
    --         message_template = " <summary> • <date> • <author> • <<sha>>", -- template for the blame message, check the Message template section for more options
    --         date_format = "%m-%d-%Y %H:%M:%S", -- template for the date, check Date format section for more options
    --         virtual_text_column = 1, -- virtual text start column, check Start virtual text at column section for more options
    --     },
    --
    -- }
}
