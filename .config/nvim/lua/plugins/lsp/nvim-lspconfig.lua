return {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function()
        local lsp_server = {
            "lua_ls",
            "clangd",
            "pyright",
            "cmake",
            "bashls",
            "jsonls",
        }
        for _, lspServer in ipairs(lsp_server) do
            vim.lsp.config(lspServer, {})
            vim.lsp.enable(lspServer)
        end
        -- vim.diagnostic.config({ virtual_text = true })
        local icons = require("plugins/utils/icons")
        vim.diagnostic.config {
            virtual_text = { current_line = true },
            float = { severity_sort = true },
            severity_sort = true,
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
                    [vim.diagnostic.severity.WARN] = icons.diagnostics.Warning,
                    [vim.diagnostic.severity.INFO] = icons.diagnostics.Information,
                    [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
                },
            },
        }
        vim.lsp.protocol.make_client_capabilities().textDocument.foldingRange = {
            dynamicRegistration = true,
            lineFoldingOnly = true,
            foldedText = true
        }
    end

}
