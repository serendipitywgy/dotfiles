if not vim.g.neovide then
    return
end

vim.o.linespace = 2

vim.g.neovide_opacity = 1.0
vim.g.neovide_floating_blur = true
vim.g.neovide_floating_corner_radius = 0.3
vim.g.neovide_cursor_animation_length = 0.08
vim.g.neovide_cursor_trail_size = 0.4
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_cursor_vfx_mode = "railgun"
vim.g.neovide_cursor_vfx_particle_lifetime = 1.2
vim.g.neovide_cursor_vfx_particle_density = 7.0
vim.g.neovide_cursor_vfx_particle_speed = 10.0
vim.g.neovide_cursor_animate_in_insert_mode = false -- 插入模式光标瞬间到位，不加动画
vim.g.neovide_detect_color_scheme = true
vim.g.neovide_cursor_hack = false
vim.g.neovide_hide_mouse_when_typing = true
vim.g.neovide_confirm_quit = true
vim.g.neovide_fullscreen = true
vim.g.neovide_remember_window_size = true
vim.g.neovide_theme = "auto"
vim.g.neovide_show_border = false
vim.g.neovide_text_gamma = 0.8
vim.g.neovide_text_contrast = 0.3

-- 字体渲染质量
vim.g.neovide_font_rendering = "SubpixelAntialiased" -- LCD 次像素抗锯齿，锐利清晰
vim.g.neovide_font_ligatures = true                 -- 编程连字（-> → ⟶, != → ≠）

-- 窗口内边距：让编辑器内容不贴边框，视觉更舒适
vim.g.neovide_padding_top = 8
vim.g.neovide_padding_bottom = 4
vim.g.neovide_padding_left = 8
vim.g.neovide_padding_right = 8

-- 性能与帧率
vim.g.neovide_refresh_rate = 60 -- 锁定 60fps，平滑滚动，避免 GPU 空转
vim.g.neovide_idle = true       -- 闲置时停止刷新，省电省 GPU

local function dec_transparency()
    vim.g.neovide_opacity = math.max(0.3, (vim.g.neovide_opacity or 0.85) - 0.05)
    vim.notify("Opacity: " .. string.format("%.0f%%", vim.g.neovide_opacity * 100))
end

local function inc_transparency()
    vim.g.neovide_opacity = math.min(1.0, (vim.g.neovide_opacity or 0.85) + 0.05)
    vim.notify("Opacity: " .. string.format("%.0f%%", vim.g.neovide_opacity * 100))
end

vim.keymap.set({ "n", "i" }, "<S-C-Left>", dec_transparency, { desc = "Decrease transparency" })
vim.keymap.set({ "n", "i" }, "<S-C-Right>", inc_transparency, { desc = "Increase transparency" })

vim.keymap.set("n", "<F11>", function()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end, { desc = "Toggle fullscreen" })
