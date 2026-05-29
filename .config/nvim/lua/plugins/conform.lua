require("conform").setup({
    format_on_save = {
        timeout_ms = 500,
        -- 返回 false 跳过保存时自动格式化
        lua = function(bufnr)
            -- 手动标记禁用（C/C++/QML 在下面设了 vim.b.autoformat = false）
            if vim.b[bufnr].autoformat == false then return false end
            -- 工作项目路径，保存时不做任何自动格式化
            if vim.fn.getcwd() == vim.fn.expand("~/future/Awork431") then return false end
            return true
        end,
    },
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
