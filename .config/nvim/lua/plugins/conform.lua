require("conform").setup({
    format_on_save = function(bufnr)
        -- 返回 nil 跳过保存时自动格式化，返回 {} 执行
        if vim.b[bufnr].autoformat == false then return nil end
        -- 工作项目路径，保存时不做任何自动格式化（按文件路径判断，不依赖当前工作目录）
        local bufpath = vim.api.nvim_buf_get_name(bufnr)
        if vim.startswith(bufpath, vim.fn.expand("~/future/Awork431")) then return nil end
        return { timeout_ms = 500 }
    end,
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

-- C/C++/QML 关闭保存时自动格式化（clangd / qmlls 格式化风格与项目不一致）
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp", "qml" },
    callback = function()
        vim.b.autoformat = false
    end,
})
