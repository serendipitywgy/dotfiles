-- 统一主题引擎：终端与 neovide 共用
-- - 主题：11 款，状态持久化到 last_colorscheme（两端共享）
-- - 透明 toggle：两端共用
-- - 字体：仅 neovide，状态持久化到 last_neovide_font

vim.opt.termguicolors = true

local M = {}

-- ============================================================
-- 主题数据
-- ============================================================

-- colorscheme 名前缀 → vim.pack 的 packadd 名（repo 末段）
local scheme_to_pack = {
    catppuccin = "nvim",
    tokyonight = "tokyonight.nvim",
    gruvbox = "gruvbox.nvim",
    kanagawa = "kanagawa.nvim",
    ["rose-pine"] = "neovim",
    everforest = "everforest",
    nightfox = "nightfox.nvim",
    melange = "melange-nvim",
    zephyr = "zephyr-nvim",
    PaperColor = "papercolor-theme",
    flexoki = "flexoki.nvim",
}

-- 按前缀长度降序排列，确保 "onedark" 优先于 "one" 匹配
local scheme_prefixes = {}
for prefix, pack in pairs(scheme_to_pack) do
    scheme_prefixes[#scheme_prefixes + 1] = { prefix = prefix, pack = pack }
end
table.sort(scheme_prefixes, function(a, b)
    return #a.prefix > #b.prefix
end)

-- 主题 → 其 opt 依赖（确保在 colorscheme 之前已 packadd）
local scheme_deps = {}

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
local legacy_neovide_theme_file = state_dir .. "/last_neovide_colorscheme"
local font_file = state_dir .. "/last_neovide_font"

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

-- 一次性迁移：旧 neovide 状态文件 → 共享文件
local function migrate_legacy_state()
    if vim.fn.filereadable(theme_file) == 1 then
        return
    end
    if vim.fn.filereadable(legacy_neovide_theme_file) == 1 then
        local legacy = read_state(legacy_neovide_theme_file, "")
        if #legacy > 0 then
            write_state(theme_file, legacy)
            pcall(os.remove, legacy_neovide_theme_file)
        end
    end
end

-- ============================================================
-- 主题加载原语
-- ============================================================

local function packadd_for_scheme(name)
    for _, entry in ipairs(scheme_prefixes) do
        if name:find(entry.prefix, 1, true) then
            pcall(vim.cmd.packadd, entry.pack)
            return
        end
    end
end

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
    local deps = scheme_deps[name] or {}
    for _, dep in ipairs(deps) do
        pcall(vim.cmd.packadd, dep)
    end
    packadd_for_scheme(name)
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
-- 字体管理（仅 neovide）
-- ============================================================

-- guifontwide 在 neovide 下不生效，中文字体直接拼进 guifont
-- Linux 字体族名用空格分隔（nerd-fonts v3 命名惯例）
local fonts = {
    "BlexMono Nerd Font Mono,LXGW WenKai Mono:h12",
    "CaskaydiaCove Nerd Font Mono,Noto Sans CJK SC:h12",
    "CodeNewRoman Nerd Font Mono,LXGW WenKai Mono:h13",
    "CommitMono Nerd Font Mono,Sarasa Fixed SC:h12",
    "DejaVuSansM Nerd Font Mono,LXGW WenKai Mono:h12",
    "EnvyCodeR Nerd Font Mono,LXGW WenKai Mono:h12",
    "FantasqueSansM Nerd Font Mono,LXGW WenKai Mono:h13",
    "FiraCode Nerd Font Mono,Sarasa Fixed SC:h12",
    "GeistMono Nerd Font Mono,LXGW WenKai Mono:h12",
    "Hack Nerd Font Mono,LXGW WenKai Mono:h12",
    "Hurmit Nerd Font Mono,LXGW WenKai Mono:h12",
    "IntoneMono Nerd Font Mono,LXGW WenKai Mono:h12",
    "Iosevka Nerd Font Mono,LXGW WenKai Mono:h13",
    "JetBrainsMono Nerd Font Mono,Sarasa Fixed SC:h12",
    "JetBrainsMono Nerd Font Mono:style=Light,Sarasa Fixed SC:h12",
    "JetBrainsMono Nerd Font Mono:style=Medium,Sarasa Fixed SC:h12",
    "JetBrainsMono Nerd Font Mono:style=SemiBold,Sarasa Fixed SC:h12",
    "Maple Mono NF CN:h12",
    "MesloLGMDZ Nerd Font Mono,Sarasa Fixed SC:h12",
    "MonaspiceAr Nerd Font Mono,LXGW WenKai Mono:h12",
    "Monoid Nerd Font Mono,Noto Sans CJK SC:h11",
    "Mononoki Nerd Font Mono,LXGW WenKai Mono:h13",
    "RecMonoLinear Nerd Font Mono,LXGW WenKai Mono:h12",
    "RobotoMono Nerd Font Mono,Sarasa Fixed SC:h12",
    "SauceCodePro Nerd Font Mono,Sarasa Fixed SC:h12",
    "UbuntuMono Nerd Font Mono,LXGW WenKai Mono:h13",
    "VictorMono Nerd Font Mono,LXGW WenKai Mono:h12",
    "Sarasa Fixed SC,Symbols Nerd Font Mono:h12",
}

local function strip_size(font_str)
    return (font_str:gsub(":h%d+$", ""))
end

local font_idx = 1
if vim.g.neovide then
    -- 持久化的字体可能带有修改过的字号，按名称匹配后用持久化值覆盖表项
    local persisted_font = read_state(font_file, fonts[1])
    local persisted_name = strip_size(persisted_font)
    for i, f in ipairs(fonts) do
        if strip_size(f) == persisted_name then
            font_idx = i
            fonts[i] = persisted_font
            break
        end
    end
end

local function switch_font(step)
    step = step or 1
    font_idx = (font_idx + step - 1) % #fonts + 1
    vim.o.guifont = fonts[font_idx]
    write_state(font_file, fonts[font_idx])
end

local function change_font_size(step)
    step = step or 1
    local font_str = fonts[font_idx]
    local size_str = font_str:match("h(%d+)$")
    if not size_str then
        vim.notify("Font size not specified: " .. font_str)
        return
    end
    local new_size = math.max(8, math.min(15, tonumber(size_str) + step))
    font_str = font_str:gsub("h%d+$", "h" .. new_size)
    fonts[font_idx] = font_str
    vim.o.guifont = font_str
    write_state(font_file, font_str)
    vim.notify(font_str)
end

local function select_font()
    local items = {}
    for i, f in ipairs(fonts) do
        local label = strip_size(f):gsub(",.*$", "")
        items[i] = { label = label, idx = i }
    end
    vim.ui.select(items, {
        prompt = "Pick font",
        format_item = function(item)
            if item.idx == font_idx then
                return "> " .. item.label .. "  (current)"
            end
            return "  " .. item.label
        end,
    }, function(choice)
        if not choice then return end
        font_idx = choice.idx
        vim.o.guifont = fonts[font_idx]
        write_state(font_file, fonts[font_idx])
        M.show()
    end)
end

local function random_font()
    font_idx = math.random(#fonts)
    vim.o.guifont = fonts[font_idx]
    write_state(font_file, fonts[font_idx])
    M.show()
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
            local deps = scheme_deps[name] or {}
            for _, dep in ipairs(deps) do
                pcall(vim.cmd.packadd, dep)
            end
            packadd_for_scheme(name)
            setup_scheme(name)
            picker:close()
            picker.preview.state.colorscheme = nil
            vim.schedule(function()
                pcall(vim.cmd.colorscheme, name)
                if vim.g.neovide then
                    vim.o.guifont = fonts[font_idx]
                end
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
    local info = (vim.g.colors_name or "?")
    if vim.g.neovide then
        info = info .. " | " .. string.gsub(vim.o.guifont or "", "_[%w]+", "")
        local vfx = vim.g.neovide_cursor_vfx_mode
        if vfx and vfx ~= "" then
            info = info .. " | VFX: " .. vfx
        end
    end
    vim.notify(info)
end

function M.set_style()
    local theme = vim.g.colors_name or ""
    local options = {
        { desc = "Theme: " .. theme, action = "theme" },
    }
    if vim.g.neovide then
        local font = string.gsub(vim.o.guifont or "", "_[%w]+", "")
        options[#options + 1] = { desc = "Font:  " .. font, action = "font" }
        options[#options + 1] = { desc = "Increase font size", action = "size_plus" }
        options[#options + 1] = { desc = "Decrease font size", action = "size_minus" }
    end
    vim.ui.select(options, {
        prompt = "Adjust theme and font",
        format_item = function(item) return item.desc end,
    }, function(choice)
        if not choice then return end
        if choice.action == "size_plus" then
            change_font_size(1); M.show()
        elseif choice.action == "size_minus" then
            change_font_size(-1); M.show()
        elseif choice.action == "theme" then
            vim.ui.select({
                { desc = "Next theme", action = "next" },
                { desc = "Previous theme", action = "prev" },
                { desc = "Pick from list", action = "list" },
                { desc = "Random theme", action = "random" },
            }, {
                prompt = "Theme: " .. theme,
                format_item = function(item) return item.desc end,
            }, function(sub)
                if not sub then return end
                if sub.action == "next" then
                    switch_theme(1); M.show()
                elseif sub.action == "prev" then
                    switch_theme(-1); M.show()
                elseif sub.action == "list" then
                    select_theme()
                elseif sub.action == "random" then
                    random_theme()
                end
            end)
        elseif choice.action == "font" then
            vim.ui.select({
                { desc = "Next font", action = "next" },
                { desc = "Previous font", action = "prev" },
                { desc = "Pick from list", action = "list" },
                { desc = "Random font", action = "random" },
            }, {
                prompt = "Font: " .. string.gsub(vim.o.guifont or "", ":h%d+$", ""):gsub(",_[%w]+", ""),
                format_item = function(item) return item.desc end,
            }, function(sub)
                if not sub then return end
                if sub.action == "next" then
                    switch_font(1); M.show()
                elseif sub.action == "prev" then
                    switch_font(-1); M.show()
                elseif sub.action == "list" then
                    select_font()
                elseif sub.action == "random" then
                    random_font()
                end
            end)
        end
    end)
end

function M.random()
    if vim.g.neovide and math.random(2) == 1 then
        random_font()
    else
        random_theme()
    end
end

-- ============================================================
-- 启动恢复 + ColorScheme 持久化
-- ============================================================

migrate_legacy_state()

local function apply_last()
    local saved = read_state(theme_file, "")
    theme_idx = find_idx(M.themes, saved) or find_idx(M.themes, "catppuccin")
    local name = M.themes[theme_idx]
    if vim.g.neovide then
        vim.o.guifont = fonts[font_idx]
        write_state(font_file, fonts[font_idx])
        -- 主题加载涉及 packadd + colorscheme，延迟到 UI 就绪后避免阻塞启动
        vim.schedule(function() M.apply_theme(name) end)
    else
        M.apply_theme(name)
    end
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

-- ColorScheme autocmd：透明状态栏 + 注释不斜体（两端共用）
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "Comment", { italic = false })
    end,
})

-- ============================================================
-- 透明 toggle（两端共用）
-- ============================================================

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
}):map("<leader>ut", { desc = "Toggle transparent mode" })

-- ============================================================
-- keymaps
-- ============================================================

vim.keymap.set("n", "<leader>us", M.set_style, { desc = "Set theme and font" })
vim.keymap.set("n", "<leader>uC", M.browse_all, { desc = "配色方案" })
vim.keymap.set("n", "<leader>uS", M.show, { desc = "Show theme and font" })
vim.keymap.set("n", "<leader>ur", M.random, { desc = "Random theme or font" })

-- ============================================================
-- 启动应用持久化主题
-- ============================================================

apply_last()

return M
