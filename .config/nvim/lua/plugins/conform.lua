require("conform").setup({
    formatters_by_ft = {
        -- 文件类型 → 格式化器列表（按顺序尝试，第一个可用的执行）
        -- 未列出的文件类型不做格式化（不兜底 LSP）
        lua = { "stylua" },
        python = { "ruff_format", "ruff_organize_imports" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        markdown = { "prettier" },
        bash = { "shfmt" },
        sh = { "shfmt" },
        cmake = { "cmake_format" },
        html = { "prettier" },
        css = { "prettier" },
        yaml = { "prettier" },
    },
})
