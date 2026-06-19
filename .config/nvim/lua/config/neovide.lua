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

local function dec_transparency()
    vim.g.neovide_opacity = math.max(0.3, (vim.g.neovide_opacity or 0.85) - 0.05)
end

local function inc_transparency()
    vim.g.neovide_opacity = math.min(1.0, (vim.g.neovide_opacity or 0.85) + 0.05)
end

vim.keymap.set({ "n", "i" }, "<F5>", dec_transparency, { desc = "Decrease transparency" })
vim.keymap.set({ "n", "i" }, "<F6>", inc_transparency, { desc = "Increase transparency" })

vim.keymap.set("n", "<F11>", function()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end, { desc = "Toggle fullscreen" })
