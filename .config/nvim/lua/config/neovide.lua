-- ~/.config/nvim/lua/config/neovide.lua
local M = {}

function M.setup()
    if vim.g.neovide then
        -- 字体设置
        vim.o.guifont = "JetBrainsMonoNL Nerd Font Mono:h11.75" -- 替换为你喜欢的字体和大小

        -- 启用光标动画
        vim.g.neovide_cursor_animation_length = 0.13
        vim.g.neovide_cursor_trail_length = 0.8
        vim.g.neovide_cursor_antialiasing = true
        vim.g.neovide_cursor_vfx_mode = "railgun" -- 光标粒子

        -- 透明度设置
        vim.g.neovide_opacity = 0.9

        -- 记住窗口大小
        vim.g.neovide_remember_window_size = true

        -- 刷新率
        vim.g.neovide_refresh_rate = 60

        -- 空闲刷新率
        vim.g.neovide_refresh_rate_idle = 5

        -- 没有空闲时的刷新率
        vim.g.neovide_no_idle = true


        -- 输入法支持
        vim.g.neovide_input_ime = true

        -- 设置 Ctrl+Shift+C/V 为复制/粘贴
        vim.keymap.set('v', '<C-S-c>', '"+y', { noremap = true, silent = true })
        vim.keymap.set('n', '<C-S-v>', '"+p', { noremap = true, silent = true })
        vim.keymap.set('i', '<C-S-v>', '<C-r>+', { noremap = true, silent = true })
        vim.keymap.set('c', '<C-S-v>', '<C-r>+', { noremap = true, silent = true })
        vim.keymap.set('t', '<C-S-v>', '<C-\\><C-n>"+pi', { noremap = true, silent = true })
        -- 浮动窗口和弹出菜单透明度
        -- vim.opt.winblend = 90 -- 浮动窗口透明度 (0-100)
        -- vim.opt.pumblend = 20 -- 弹出菜单透明度 (0-100)

        vim.g.neovide_scale_factor = 1.0
        local change_scale_factor = function(delta)
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
        end
        vim.keymap.set("n", "<C-=>", function() change_scale_factor(1.25) end)
        vim.keymap.set("n", "<C-->", function() change_scale_factor(1 / 1.25) end)

        -- 全屏模式
        vim.g.neovide_fullscreen = false
        -- 切换全屏的函数
        local toggle_fullscreen = function()
            vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
        end

        -- 设置快捷键 F11 切换全屏 (Linux 常用的全屏快捷键)
        vim.keymap.set('n', '<F11>', toggle_fullscreen)
    end
end

return M
