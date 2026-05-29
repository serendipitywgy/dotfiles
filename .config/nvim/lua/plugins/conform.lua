require("conform").setup({
    format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
        lua = function(bufnr)
            if vim.b[bufnr].autoformat == false then return false end
            if vim.fn.getcwd() == "/home/aoi/future/Awork431" then return false end
            return true
        end,
    },
    formatters_by_ft = {
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
        ["_"] = { "lsp" },
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp", "qml" },
    callback = function()
        vim.b.autoformat = false
    end,
})
