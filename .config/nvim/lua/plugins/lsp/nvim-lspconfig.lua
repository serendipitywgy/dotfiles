return {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function()
        local lsp_server = {
            "lua_ls",
            "clangd",
        }
        for _, lspServer in ipairs(lsp_server) do
            vim.lsp.config(lspServer, {})
            vim.lsp.enable(lspServer)
        end
        vim.diagnostic.config({ virtual_text = true })
    end

}
