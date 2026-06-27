-- 等插件加载完再执行
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufReadPost' }, {
    once     = true,
    callback = function()
        require("nvim-web-devicons").setup({})
        require("bufferline").setup({
            options = {
                -- 缓冲区编号
                numbers = "ordinal",
                -- 按目录分组排序
                sort_by = "directory",
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
                            symbol = " "
                        elseif level == "warning" then
                            symbol = " "
                        elseif level == "info" then
                            symbol = " "
                        else
                            symbol = " "
                        end
                        indicator = indicator .. number .. symbol
                    end
                    return indicator
                end,
            },
            -- 链接到 vim 标准 hl 组，自动跟随 colorscheme
            highlights = {
                fill              = { link = "Normal" },
                background        = { link = "TabLine" },
                buffer            = { link = "TabLine" },
                buffer_visible    = { link = "TabLine" },
                buffer_selected   = { link = "Normal" },
                separator         = { link = "Normal" },
                separator_visible = { link = "Normal" },
                tab               = { link = "TabLine" },
                tab_selected      = { link = "TabLineSel" },
                tab_close         = { link = "TabLine" },
            },
        })

        -- 3. 注册按键
        local set = vim.keymap.set
        set("n", "<leader>bp", ":BufferLinePick<CR>", { silent = true, desc = "选择缓冲区" })
        set("n", "<leader>bc", ":BufferLinePickClose<CR>", { silent = true, desc = "选择关闭" })
        set("n", "<leader>bO", ":BufferLineCloseOthers<CR>", { silent = true, desc = "关闭其他缓冲区" })
    end,
})

-- 切换 colorscheme 时清图标缓存，使 BufferLine* 图标色跟随 hl 链接更新
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        pcall(require("bufferline.highlights").reset_icon_hl_cache)
    end,
})
