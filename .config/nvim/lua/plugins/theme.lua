-- 建议开启真彩
vim.opt.termguicolors = true

-- 持久化：记住最后一次选择的主题，并在启动时应用
local theme_file = vim.fn.stdpath("state") .. "/last_colorscheme"

local function apply_last_theme()
    local ok, name = pcall(function()
        return vim.fn.readfile(theme_file)[1]
    end)
    if ok and name and #name > 0 then
        pcall(vim.cmd.colorscheme, name)
    else
        -- 初次使用时默认主题（可改）
        pcall(vim.cmd.colorscheme, "catppuccin")
    end
end
apply_last_theme()

-- 切主题后统一覆盖高亮，并保存当前主题名
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        local name = vim.g.colors_name or ""
        if #name > 0 then
            pcall(vim.fn.writefile, { name }, theme_file)
        end
        -- 透明状态栏 + 注释不斜体
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "Comment", { italic = false })
    end,
})

-- 可选：catppuccin 的额外设置（不强制应用主题）
pcall(function()
    require("catppuccin").setup({
        -- transparent_background = true, -- 不需要透明背景
        styles = { comments = {} },
    })
end)

vim.g.transparent = false

Snacks.toggle.new({
    name = "Transparent Mode",
    get = function() return vim.g.transparent end,
    set = function(state)
        vim.g.transparent = state
        local groups = { "Normal", "NormalFloat", "LineNr", "Folded", "SignColumn", "NonText", "EndOfBuffer" }
        local status_groups = { "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel" }
        local bufferline_groups = {
            "BufferLine.Background", "BufferLineFill", "BufferLineBuffer",
            "BufferLineBufferVisible", "BufferLineBufferSelected",
            "BufferLineClose", "BufferLineCloseVisible",
            "BufferLineCloseSelected", "BufferLineDuplicate",
            "BufferLineDuplicateSelected", "BufferLineModified",
            "BufferLineModifiedVisible", "BufferLineModifiedSelected",
            "BufferLineSeparator", "BufferLineSeparatorVisible",
            "BufferLineSeparatorSelected", "BufferLineGroupHighlight",
            "BufferLineGroupSeparator", "BufferLineGroupSeparatorSelected",
        }
        if state then
            for _, grp in ipairs(groups) do vim.cmd(("hi! %s ctermbg=NONE guibg=NONE"):format(grp)) end
            for _, grp in ipairs(status_groups) do vim.cmd(("hi! %s ctermbg=NONE guibg=NONE"):format(grp)) end
            for _, grp in ipairs(bufferline_groups) do vim.cmd(("hi! %s ctermbg=NONE guibg=NONE"):format(grp)) end
        else
            for _, grp in ipairs(groups) do vim.cmd(("hi! default %s ctermbg=NONE guibg=NONE"):format(grp)) end
            for _, grp in ipairs(status_groups) do vim.cmd(("hi! default %s ctermbg=NONE guibg=NONE"):format(grp)) end
            for _, grp in ipairs(bufferline_groups) do vim.cmd(("hi! default %s ctermbg=NONE guibg=NONE"):format(grp)) end
        end
    end,
}):map("<leader>utp", { desc = "Toggle transparent mode" })
