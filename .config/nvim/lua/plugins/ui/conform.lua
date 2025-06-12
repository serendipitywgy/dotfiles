return {
    {
        "stevearc/conform.nvim",
        dependencies = { "mason.nvim" }, -- 如果你使用 mason.nvim
        lazy = true,
        cmd = "ConformInfo",
        event = "BufWritePre",
        opts = {
            default_format_opts = {
                timeout_ms = 3000,
                async = false,
                quiet = false,
                lsp_format = "fallback",
            },
            formatters_by_ft = {
                lua = { "stylua" },
                fish = { "fish_indent" },
                sh = { "shfmt" },
                -- 添加其他文件类型的格式化器
                cpp = { "clang-format" }, -- 添加 C++ 格式化器
                c = { "clang-format" },   -- 添加 C 格式化器
                ["_"] = { "trim_whitespace" },
            },
            formatters = {
                injected = { options = { ignore_errors = true } },
            },
            format_on_save = function(_)
                -- Disable with a global or buffer-local variable
                if vim.g.enable_autoformat then
                    return { timeout_ms = 500, lsp_format = "fallback" }
                end
            end,
        },
        init = function()
            vim.g.enable_autoformat = false
            require("snacks").toggle
                .new({
                    id = "auto_format",
                    name = "Auto format",
                    get = function()
                        return vim.g.enable_autoformat
                    end,
                    set = function(state)
                        vim.g.enable_autoformat = state
                    end,
                })
                :map("<leader>tf")
        end,
        config = function(_, opts)
            require("conform").setup(opts)
        end,
    },
}
