-- 声明主插件 + 依赖
vim.pack.add({
    { src = "https://github.com/akinsho/bufferline.nvim" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
})
-- 等插件加载完再执行
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufReadPost' }, {
    once     = true,
    callback = function()
        -- 1. 先 setup devicons（bufferline 依赖它）
        require("nvim-web-devicons").setup({})

        -- 2. 再 setup bufferline
        require("bufferline").setup({
            options = {
                -- 侧边栏偏移
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "Neo-tree",
                        highlight = "Directory",
                        text_align = "left",
                    },
                    {
                        filetype = "snacks_layout_box",
                    },
                },
                -- 指示器样式
                indicator = {
                    style = "underline",
                },
                -- LSP 诊断
                diagnostics = "nvim_lsp",
                diagnostics_indicator = function(_, _, diagnostics_dict, _)
                    local indicator = " "
                    for level, number in pairs(diagnostics_dict) do
                        local symbol
                        if level == "error" then
                            symbol = " "
                        elseif level == "warning" then
                            symbol = " "
                        else
                            symbol = " "
                        end
                        indicator = indicator .. number .. symbol
                    end
                    return indicator
                end,
            },
        })

        -- 3. 注册按键
        local set = vim.keymap.set
        set("n", "<leader>bp", ":BufferLinePick<CR>", { silent = true, desc = "Pick buffer" })
        set("n", "<leader>bc", ":BufferLinePickClose<CR>", { silent = true, desc = "Pick close" })
    end,
})
