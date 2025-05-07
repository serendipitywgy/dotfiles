return {
    {
        "stevearc/conform.nvim",
        dependencies = { "mason.nvim" }, -- 如果你使用 mason.nvim
        lazy = true,
        cmd = "ConformInfo",
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
            },
            formatters = {
                injected = { options = { ignore_errors = true } },
            },
        },
        config = function(_, opts)
            require("conform").setup(opts)
        end,
    },
}
