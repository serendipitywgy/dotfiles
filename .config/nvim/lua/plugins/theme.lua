-- 建议开启真彩
vim.opt.termguicolors = true

-- 持久化：记住最后一次选择的主题，并在启动时应用
local theme_file = vim.fn.stdpath("state") .. "/last_colorscheme"

-- colorscheme 名 → opt 包名（vim.pack 用 repo 末段作名字）
local scheme_to_pack = {
    catppuccin = "nvim",
    tokyonight = "tokyonight.nvim",
    gruvbox = "gruvbox.nvim",
    kanagawa = "kanagawa.nvim",
    ["rose-pine"] = "neovim",
    onedark = "onedark.nvim",
    everforest = "everforest",
    astro = "astrotheme",
}

local function packadd_for_scheme(name)
    for prefix, pack in pairs(scheme_to_pack) do
        if name:find(prefix, 1, true) then
            pcall(vim.cmd.packadd, pack)
            return
        end
    end
end

local function apply_last_theme()
    local ok, name = pcall(function()
        return vim.fn.readfile(theme_file)[1]
    end)
    if not ok or not name or #name == 0 then
        name = "catppuccin"
    end
    packadd_for_scheme(name)
    if name:find("catppuccin", 1, true) then
        pcall(function()
            require("catppuccin").setup({ styles = { comments = {} } })
        end)
    end
    pcall(vim.cmd.colorscheme, name)
end
apply_last_theme()

-- 切主题后统一覆盖高亮，并保存当前主题名
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        local name = vim.g.colors_name or ""
        if #name > 0 then
            packadd_for_scheme(name)
            pcall(vim.fn.writefile, { name }, theme_file)
        end
        -- 透明状态栏 + 注释不斜体
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "Comment", { italic = false })
    end,
})


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
