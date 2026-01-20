-- vim.pack.add({
--     { src = "https://github.com/catppuccin/nvim" },
-- })
--
-- require("catppuccin").setup()
-- vim.cmd("colorscheme catppuccin")
-- vim.cmd.hi("statusline guibg=NONE")
vim.pack.add({
    { src = "https://github.com/ibhagwan/fzf-lua" },
    { src = "https://github.com/catppuccin/nvim" },

    -- 主题集合（可增删）
    { src = "https://github.com/folke/tokyonight.nvim" },
    { src = "https://github.com/ellisonleao/gruvbox.nvim" },
    { src = "https://github.com/rebelot/kanagawa.nvim" },
    { src = "https://github.com/EdenEast/nightfox.nvim" },
    { src = "https://github.com/rose-pine/neovim" },
    { src = "https://github.com/neanias/everforest-nvim" },
    { src = "https://github.com/navarasu/onedark.nvim" },
})
-- 建议开启真彩
vim.opt.termguicolors = true

-- 检查 fzf 二进制
if vim.fn.executable("fzf") ~= 1 then
    vim.schedule(function()
        vim.notify("未检测到 fzf 二进制，请先安装 fzf，否则 fzf-lua 将不可用。", vim.log.levels.WARN)
    end)
end

-- fzf-lua 配置 + 主题选择映射
local ok_fzf, fzf = pcall(require, "fzf-lua")
if ok_fzf then
    fzf.setup({
        winopts = {
            height = 0.85,
            width = 0.80,
            preview = {
                layout = "vertical",
                vertical = "down:60%",
            },
        },
        keymap = {
            builtin = {
                ["<C-p>"] = "toggle-preview",
            },
            fzf = {
                ["tab"] = "toggle+down",
                ["shift-tab"] = "toggle+up",
            },
        },
    })
    -- 主题弹窗（默认带预览）
    vim.keymap.set("n", "<leader>ut", function()
        fzf.colorschemes()
    end, { desc = "选择主题（fzf-lua）" })
end

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

-- vim.cmd.hi("statusline guibg=NONE")
