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

-- 切换透明模式：将指定高亮组的背景设为 NONE（完全透明）
-- 原理：
--   1. hi! 强制覆盖插件/主题的默认高亮定义
--   2. ctermbg=NONE / guibg=NONE 设置终端/GUI 背景为"无"（透明）
--   3. default 在关闭时恢复 Neovim 内置默认值
local function toggle_transparent()
    vim.g.transparent = not vim.g.transparent
    local transparent = vim.g.transparent

    -- 基础高亮组：编辑器正文区域
    --   Normal: 主编辑区背景
    --   NormalFloat: 浮动窗口背景
    --   LineNr: 行号列
    --   Folded: 折叠行
    --   SignColumn: 符号列（git sign 等）
    --   NonText / EndOfBuffer: ~ 行和缓冲区末尾
    local groups = { "Normal", "NormalFloat", "LineNr", "Folded", "SignColumn", "NonText", "EndOfBuffer" }

    -- 状态栏高亮组：底部状态栏
    --   StatusLine: 当前窗口状态栏
    --   StatusNC: 非当前窗口状态栏
    --   TabLine: 顶部标签页栏
    --   TabLineFill: 标签页栏填充
    --   TabLineSel: 选中的标签页
    local status_groups = { "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel" }

    -- BufferLine 高亮组：顶部缓冲标签栏（bufferline.nvim 插件）
    --   包含：背景、缓冲区、关闭按钮、选中状态、分隔符等所有子组件
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

    if transparent then
        -- 开启透明：设置为 NONE
        for _, grp in ipairs(groups) do
            vim.cmd(("hi! %s ctermbg=NONE guibg=NONE"):format(grp))
        end
        for _, grp in ipairs(status_groups) do
            vim.cmd(("hi! %s ctermbg=NONE guibg=NONE"):format(grp))
        end
        for _, grp in ipairs(bufferline_groups) do
            vim.cmd(("hi! %s ctermbg=NONE guibg=NONE"):format(grp))
        end
    else
        -- 关闭透明：恢复 Neovim 默认值
        for _, grp in ipairs(groups) do
            vim.cmd(("hi! default %s ctermbg=NONE guibg=NONE"):format(grp))
        end
        for _, grp in ipairs(status_groups) do
            vim.cmd(("hi! default %s ctermbg=NONE guibg=NONE"):format(grp))
        end
        for _, grp in ipairs(bufferline_groups) do
            vim.cmd(("hi! default %s ctermbg=NONE guibg=NONE"):format(grp))
        end
    end
    vim.notify("透明模式: " .. (transparent and "开启" or "关闭"), vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>utp", toggle_transparent, { desc = "切换透明模式" })
