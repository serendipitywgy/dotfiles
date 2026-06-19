-- neovide 专属：主题与字体轮转 + 持久化
-- 终端 nvim 完全跳过本文件，主题持久化由 lua/plugins/theme.lua 负责
if not vim.g.neovide then
    return
end

local state_dir = vim.fn.stdpath("state")
local theme_file = state_dir .. "/last_neovide_colorscheme"
local font_file = state_dir .. "/last_neovide_font"

-- colorscheme 名前缀 → vim.pack 的 packadd 名（repo 末段）
local scheme_to_pack = {
    catppuccin = "nvim",
    astro = "astrotheme",
    tokyonight = "tokyonight.nvim",
    gruvbox = "gruvbox.nvim",
    kanagawa = "kanagawa.nvim",
    ["rose-pine"] = "neovim",
    onedark = "onedark.nvim",
    everforest = "everforest",
    bluloco = "bluloco.nvim",
    dracula = "dracula.nvim",
    github = "github-nvim-theme",
    ["gruvbox-material"] = "gruvbox-material",
    hybrid = "hybrid.nvim",
    yellowbeans = "yellowbeans.nvim",
    melange = "melange-nvim",
    miasma = "miasma.nvim",
    ["monokai-pro"] = "monokai-pro.nvim",
    nightfox = "nightfox.nvim",
    one = "vim-one",
    onenord = "onenord.nvim",
    palenightfall = "palenightfall.nvim",
    PaperColor = "papercolor-theme",
    posterpole = "posterpole.nvim",
    sonokai = "sonokai",
    vscode = "vscode.nvim",
    zephyr = "zephyr-nvim",
}

local function packadd_for_scheme(name)
    for prefix, pack in pairs(scheme_to_pack) do
        if name:find(prefix, 1, true) then
            pcall(vim.cmd.packadd, pack)
            return
        end
    end
end

-- 个别主题需要 setup 才能生效或调整样式
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

-- 字体表（neovide 的 guifont 格式：英文NF,中文等宽:h字号）
-- guifontwide 在 neovide 下不生效，中文字体直接拼进 guifont
-- Linux 字体族名用空格分隔（nerd-fonts v3 命名惯例），原 temp 配置的下划线命名仅 Windows 有效
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

local themes = {
    "bluloco",
    "catppuccin",
    "dracula",
    "everforest",
    "github_dark_dimmed",
    "gruvbox-material",
    "hybrid",
    "yellowbeans",
    "kanagawa",
    "melange",
    "miasma",
    "monokai-pro",
    "nightfox",
    "one",
    "onedark",
    "onenord",
    "palenightfall",
    "PaperColor",
    "posterpole",
    "rose-pine",
    "sonokai",
    "tokyonight",
    "vscode",
    "zephyr",
    "astro",
}

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

local function find_idx(list, value)
    for i, v in ipairs(list) do
        if v == value then
            return i
        end
    end
    return nil
end

-- 字体名去掉字号后缀，用于跨重启匹配（字号会被 change_font_size 修改）
local function strip_size(font_str)
    return (font_str:gsub(":h%d+$", ""))
end

-- 持久化的字体可能带有修改过的字号，按名称匹配后用持久化值覆盖表项
local persisted_font = read_state(font_file, fonts[1])
local persisted_name = strip_size(persisted_font)
local font_idx = 1
for i, f in ipairs(fonts) do
    if strip_size(f) == persisted_name then
        font_idx = i
        fonts[i] = persisted_font
        break
    end
end

local theme_idx = find_idx(themes, read_state(theme_file, "")) or 1

local function apply_theme(name)
    packadd_for_scheme(name)
    setup_scheme(name)
    pcall(vim.cmd.colorscheme, name)
end

local function switch_theme(step)
    step = step or 1
    theme_idx = (theme_idx + step - 1) % #themes + 1
    local name = themes[theme_idx]
    apply_theme(name)
    write_state(theme_file, name)
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

local function show_style()
    local info = (vim.g.colors_name or "?") .. " | " .. string.gsub(vim.o.guifont or "", "_[%w]+", "")
    vim.notify(info)
end

local function set_style()
    local theme = vim.g.colors_name or ""
    local font = string.gsub(vim.o.guifont or "", "_[%w]+", "")
    local options = {
        { desc = "switch theme  - " .. theme, value = 1 },
        { desc = "switch font   - " .. font, value = 2 },
        { desc = "increase font size", value = 3 },
        { desc = "decrease font size", value = 4 },
    }
    vim.ui.select(options, {
        prompt = "Adjust theme and font",
        format_item = function(item)
            return item.desc
        end,
    }, function(choice)
        if not choice then
            return
        end
        if choice.value == 1 then
            switch_theme(1)
        elseif choice.value == 2 then
            switch_font(1)
        elseif choice.value == 3 then
            change_font_size(1)
        elseif choice.value == 4 then
            change_font_size(-1)
        end
        show_style()
    end)
end

-- 手动 :colorscheme 切换时同步持久化与索引（先注册，确保启动时 apply_theme 也能触发持久化）
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        local name = vim.g.colors_name or ""
        if #name == 0 then
            return
        end
        local idx = find_idx(themes, name)
        if idx then
            theme_idx = idx
            write_state(theme_file, name)
        end
    end,
})

-- 启动时应用持久化的主题与字体
vim.o.guifont = fonts[font_idx]
write_state(font_file, fonts[font_idx])
apply_theme(themes[theme_idx])

vim.keymap.set("n", "<A-f>", set_style, { desc = "Set theme and font (neovide)" })
vim.keymap.set("n", "<A-F>", show_style, { desc = "Show theme and font (neovide)" })
