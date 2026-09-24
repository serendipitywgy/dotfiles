-- 统一主题引擎
-- - 主题：11 款，状态持久化到 last_colorscheme
-- - 支持透明背景切换

vim.opt.termguicolors = true

local M = {}

-- ============================================================
-- 主题数据
-- ============================================================

M.themes = {
    "catppuccin", "everforest", "flexoki", "gruvbox",
    "kanagawa", "melange", "nightfox", "PaperColor",
    "rose-pine", "tokyonight", "zephyr",
}

-- ============================================================
-- 状态持久化
-- ============================================================

local state_dir = vim.fn.stdpath("state")
local theme_file = state_dir .. "/last_colorscheme"

local function read_state(path, default)
    local ok, line = pcall(function()
        return vim.fn.readfile(path)[1]
    end)
    if ok and line and #line > 0 then
        return line
    end
    return default
end

local function write_state(path, content)
    pcall(vim.fn.writefile, { content }, path)
end

-- ============================================================
-- 主题加载原语
-- ============================================================

local function setup_scheme(name)
    if name:find("catppuccin", 1, true) then
        pcall(function()
            require("catppuccin").setup({ styles = { comments = {} } })
        end)
    elseif name:find("rose-pine", 1, true) then
        pcall(function()
            require("rose-pine").setup({ styles = { italic = false } })
        end)
    end
end

function M.apply_theme(name)
    setup_scheme(name)
    local ok, err = pcall(vim.cmd.colorscheme, name)
    if not ok then
        vim.notify("colorscheme '" .. name .. "' failed: " .. tostring(err), vim.log.levels.WARN)
    end
end

local function find_idx(list, value)
    for i, v in ipairs(list) do
        if v == value then return i end
    end
    return nil
end

-- ============================================================
-- 主题切换 UI
-- ============================================================

local theme_idx = 1

local function switch_theme(step)
    step = step or 1
    theme_idx = (theme_idx + step - 1) % #M.themes + 1
    local name = M.themes[theme_idx]
    M.apply_theme(name)
    write_state(theme_file, name)
end

local function find_colorschemes()
    local vimruntime = vim.env.VIMRUNTIME
    local rtp = vim.o.runtimepath
    local files = vim.fn.globpath(rtp, "colors/*", false, true)
    local items = {}
    for _, file in ipairs(files) do
        local name = vim.fn.fnamemodify(file, ":t:r")
        local ext = vim.fn.fnamemodify(file, ":e")
        if (ext == "vim" or ext == "lua") and vimruntime and file:sub(1, #vimruntime) ~= vimruntime then
            items[#items + 1] = { text = name, file = file }
        end
    end
    return items
end

local function select_theme()
    Snacks.picker.pick({
        title = "Colorschemes",
        items = find_colorschemes(),
        format = "text",
        preview = "colorscheme",
        confirm = function(picker, item)
            if not item then return end
            local name = item.text
            setup_scheme(name)
            picker:close()
            picker.preview.state.colorscheme = nil
            vim.schedule(function()
                pcall(vim.cmd.colorscheme, name)
                local idx = find_idx(M.themes, name)
                if idx then
                    theme_idx = idx
                end
                write_state(theme_file, name)
                M.show()
            end)
        end,
    })
end

function M.browse_all()
    Snacks.picker.pick({
        title = "Colorschemes",
        items = find_colorschemes(),
        format = "text",
        preview = "colorscheme",
    })
end

local function random_theme()
    theme_idx = math.random(#M.themes)
    M.apply_theme(M.themes[theme_idx])
    write_state(theme_file, M.themes[theme_idx])
    M.show()
end

function M.show()
    vim.notify(vim.g.colors_name or "?")
end

function M.set_style()
    local theme = vim.g.colors_name or ""
    vim.ui.select({
        { desc = "Next theme", action = "next" },
        { desc = "Previous theme", action = "prev" },
        { desc = "Pick from list", action = "list" },
        { desc = "Random theme", action = "random" },
    }, {
        prompt = "Theme: " .. theme,
        format_item = function(item) return item.desc end,
    }, function(choice)
        if not choice then return end
        if choice.action == "next" then
            switch_theme(1); M.show()
        elseif choice.action == "prev" then
            switch_theme(-1); M.show()
        elseif choice.action == "list" then
            select_theme()
        elseif choice.action == "random" then
            random_theme()
        end
    end)
end

function M.random()
    random_theme()
end

-- ============================================================
-- 启动恢复 + ColorScheme 持久化
-- ============================================================

local function apply_last()
    local saved = read_state(theme_file, "")
    theme_idx = find_idx(M.themes, saved) or find_idx(M.themes, "catppuccin")
    local name = M.themes[theme_idx]
    M.apply_theme(name)
end

-- ColorScheme autocmd：同步索引 + 持久化（仅记录 M.themes 内的主题）
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        local name = vim.g.colors_name or ""
        if #name == 0 then return end
        local idx = find_idx(M.themes, name)
        if idx then
            theme_idx = idx
            write_state(theme_file, name)
        end
    end,
})

-- ColorScheme autocmd：透明状态栏 + 注释不斜体
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "Comment", { italic = false })
    end,
})

-- ============================================================
-- 透明 toggle
-- ============================================================

vim.g.transparent = false

local transparent_groups = {
    "Normal", "NormalFloat", "LineNr", "Folded", "SignColumn", "NonText", "EndOfBuffer",
    "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel",
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

local function apply_transparency()
    for _, group in ipairs(transparent_groups) do
        vim.cmd.highlight({ group, "ctermbg=NONE", "guibg=NONE", bang = true })
    end
end

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        if vim.g.transparent then
            apply_transparency()
        end
    end,
})

Snacks.toggle.new({
    name = "Transparent Mode",
    get = function() return vim.g.transparent end,
    set = function(state)
        vim.g.transparent = state
        if state then
            apply_transparency()
        else
            M.apply_theme(vim.g.colors_name or M.themes[theme_idx])
        end
    end,
}):map("<leader>ut", { desc = "Toggle transparent mode" })

-- ============================================================
-- keymaps
-- ============================================================

vim.keymap.set("n", "<leader>us", M.set_style, { desc = "Set theme" })
vim.keymap.set("n", "<leader>uC", M.browse_all, { desc = "配色方案" })
vim.keymap.set("n", "<leader>uS", M.show, { desc = "Show theme" })
vim.keymap.set("n", "<leader>ur", M.random, { desc = "Random theme" })

-- ============================================================
-- 启动应用持久化主题
-- ============================================================

apply_last()

return M
