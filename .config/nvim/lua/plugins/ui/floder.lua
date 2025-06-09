-- ufo关于折叠的设置
vim.o.foldcolumn = "0" -- '0' is not bad,其他的会有奇怪的数字
vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

return {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    config = function()
        -- Option 2: nvim lsp as LSP client
        -- Tell the server the capability of foldingRange,
        -- Neovim hasn't added foldingRange to default capabilities, users must add it manually
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
        }
        local language_servers = vim.lsp.get_clients() -- or list servers manually like {'gopls', 'clangd'}
        for _, ls in ipairs(language_servers) do
            require("lspconfig")[ls].setup({
                capabilities = capabilities,
                -- you can add other fields for setting up lsp server in this table
            })
        end
        require("ufo").setup()
        -- Option 3: treesitter as a main provider instead
        -- Only depend on `nvim-treesitter/queries/filetype/folds.scm`,
        -- performance and stability are better than `foldmethod=nvim_treesitter#foldexpr()`
        require("ufo").setup({
            provider_selector = function(bufnr, filetype, buftype)
                return { "treesitter", "indent" }
            end,
        })
        -- 键盘映射,这里的按键会打开或折叠全部的可折叠位置
        vim.keymap.set("n", "za", function()
            local winid = require('ufo').peekFoldedLinesUnderCursor()
            if not winid then
                vim.cmd("normal! za") -- 切换当前光标下的折叠状态
            end
        end, { desc = "Toggle fold under cursor" })
        vim.keymap.set("n", "zr", require("ufo").openAllFolds)
        vim.keymap.set("n", "zm", require("ufo").closeAllFolds)
        -- 更精细的层级控制
        -- vim.keymap.set("n", "z1", function() require("ufo").closeFoldsWith(1) end, { desc = "Close folds with level 1" })
        -- vim.keymap.set("n", "z2", function() require("ufo").closeFoldsWith(2) end, { desc = "Close folds with level 2" })
        -- vim.keymap.set("n", "z3", function() require("ufo").closeFoldsWith(3) end, { desc = "Close folds with level 3" })
        -- vim.keymap.set("n", "z4", function() require("ufo").closeFoldsWith(4) end, { desc = "Close folds with level 4" })
    end,
}
