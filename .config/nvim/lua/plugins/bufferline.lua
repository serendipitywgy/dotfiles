-- 等插件加载完再执行
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufReadPost' }, {
    once     = true,
    callback = function()
        require("nvim-web-devicons").setup({})
        require("bufferline").setup({
            options = {
                -- 侧边栏偏移
                offsets = {
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
        set("n", "<leader>bp", ":BufferLinePick<CR>", { silent = true, desc = "选择缓冲区" })
        set("n", "<leader>bc", ":BufferLinePickClose<CR>", { silent = true, desc = "选择关闭" })
    end,
})
