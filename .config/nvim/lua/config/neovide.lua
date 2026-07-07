if not vim.g.neovide then
    return
end

vim.o.linespace = 0                                          -- 行间距：0 表示无额外行间距

vim.g.neovide_opacity = 1.0                                  -- 窗口不透明度：1.0=不透明，0.0=全透明
vim.g.neovide_floating_blur = true                           -- 浮动窗口（LSP 文档/补全菜单等）背景模糊效果
vim.g.neovide_floating_corner_radius = 0.3                   -- 浮动窗口圆角半径（行高百分比，0~1）
vim.g.neovide_cursor_animation_length = 0.08                 -- 光标移动动画时长（秒），长距离移动
vim.g.neovide_cursor_short_animation_length = 0.04           -- 光标短距离（同/邻行）动画时长（秒）
vim.g.neovide_cursor_trail_size = 0.4                        -- 光标拖尾大小（0~1，越大尾巴越长）
vim.g.neovide_cursor_antialiasing = true                     -- 光标抗锯齿，关闭后光标边缘更锐利但有锯齿
-- 光标特效模式对照表（可设为单个字符串或数组随机轮换）：
--   ""          无粒子（默认）
--   "railgun"   光轨拖尾
--   "torpedo"   鱼雷状粒子喷射
--   "pixiedust" 小精灵闪烁
--   "sonicboom" 声爆环扩散
--   "ripple"    水波涟漪
--   "wireframe" 线框轮廓
-- 实时切换：:lua vim.g.neovide_cursor_vfx_mode = "sonicboom"
-- vim.g.neovide_cursor_vfx_mode 由下方 <leader>uv 管理 + 持久化，不在此硬编码
vim.g.neovide_cursor_vfx_particle_lifetime = 1.2             -- 特效粒子存活时间（秒）
vim.g.neovide_cursor_vfx_particle_density = 7.0              -- 特效粒子密度（越大粒子越多）
vim.g.neovide_cursor_vfx_particle_speed = 10.0               -- 特效粒子速度
vim.g.neovide_cursor_animate_in_insert_mode = false          -- 插入模式光标瞬间到位，不加动画（false=关动画）
vim.g.neovide_detect_color_scheme = false                    -- 关闭系统亮暗检测，由 vim.o.background 手动控制
vim.o.background = "dark"                                    -- 强制锁暗色，确保 colorscheme 不走亮色变体
vim.g.neovide_cursor_hack = false                            -- 旧版显卡/驱动光标兼容性 hack（无问题请关闭）
vim.g.neovide_hide_mouse_when_typing = true                  -- 打字时自动隐藏鼠标指针
vim.g.neovide_confirm_quit = true                            -- 退出时弹出确认对话框
vim.g.neovide_fullscreen = false                             -- 启动时是否直接进入全屏模式
vim.g.neovide_remember_window_size = true                    -- 关闭时记住窗口位置和尺寸，下次启动恢复
vim.g.neovide_theme = "auto"                                 -- 标题栏主题：auto（跟随系统）/light/dark
vim.g.neovide_show_border = false                            -- 是否绘制窗口边框（macOS 无边框窗口风格）
vim.g.neovide_text_gamma = 0.8                               -- 文本伽马校正，影响字体笔画粗细（0.5~1.0）
vim.g.neovide_text_contrast = 0.3                            -- 文本对比度，越大黑白越分明
vim.g.neovide_pixel_geometry = "RGBH"                        -- 子像素排列：RGBH（水平）/RGBV（垂直），影响字体渲染

-- 字体渲染：模式选择影响字体清晰度与风格
vim.g.neovide_font_rendering = "SubpixelAntialiased"         -- 字体渲染模式：SubpixelAntialiased/SubpixelHintedRendering/GrayscaleHintedRendering
vim.g.neovide_font_ligatures = true                          -- 启用编程连字（->→⟶, !=→≠, >=→≥ 等）

-- 窗口内边距：让编辑器内容不贴边框，视觉更舒适
vim.g.neovide_padding_top = 1                                -- 窗口上边距（像素）
vim.g.neovide_padding_bottom = 1                             -- 窗口下边距（像素）
vim.g.neovide_padding_left = 4                               -- 窗口左边距（像素）
vim.g.neovide_padding_right = 4                              -- 窗口右边距（像素）

-- LSP 进度条（顶部）
vim.g.neovide_progress_bar_enabled = true                    -- 顶部显示 LSP 加载进度条

-- 性能与帧率
vim.g.neovide_refresh_rate = 60                              -- 刷新率上限（fps），锁定 60 避免 GPU 空转
vim.g.neovide_idle = true                                    -- 闲置时停止刷新帧画面，省电省 GPU

local function dec_transparency()
    vim.g.neovide_opacity = math.max(0.3, (vim.g.neovide_opacity or 0.85) - 0.05)
    vim.notify("Opacity: " .. string.format("%.0f%%", vim.g.neovide_opacity * 100))
end

local function inc_transparency()
    vim.g.neovide_opacity = math.min(1.0, (vim.g.neovide_opacity or 0.85) + 0.05)
    vim.notify("Opacity: " .. string.format("%.0f%%", vim.g.neovide_opacity * 100))
end

vim.keymap.set({ "n", "i" }, "<S-C-Left>", dec_transparency, { desc = "降低窗口透明度" })
vim.keymap.set({ "n", "i" }, "<S-C-Right>", inc_transparency, { desc = "提高窗口透明度" })

vim.keymap.set({ "n", "i", "v", "c", "t" }, "<C-S-v>", function()
    vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end, { silent = true, desc = "从系统剪贴板粘贴" })

vim.keymap.set({ "n", "i", "v", "t" }, "<F11>", function()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end, { desc = "切换全屏模式" })

-- ============================================================
-- 光标特效管理（<leader>uv 切换，不持久化）
-- ============================================================

local vfx_modes = {
    { name = "none       无粒子（默认）",  mode = "" },
    { name = "railgun    光轨拖尾",        mode = "railgun" },
    { name = "torpedo    鱼雷状粒子",      mode = "torpedo" },
    { name = "pixiedust  小精灵闪烁",      mode = "pixiedust" },
    { name = "sonicboom  声爆环扩散",      mode = "sonicboom" },
    { name = "ripple     水波涟漪",        mode = "ripple" },
    { name = "wireframe  线框轮廓",        mode = "wireframe" },
}

local vfx_idx = 6
vim.g.neovide_cursor_vfx_mode = vfx_modes[vfx_idx].mode

local function switch_vfx(step)
    step = step or 1
    vfx_idx = (vfx_idx + step - 1) % #vfx_modes + 1
    vim.g.neovide_cursor_vfx_mode = vfx_modes[vfx_idx].mode
    vim.notify("VFX: " .. vfx_modes[vfx_idx].name)
end

local function select_vfx()
    local items = {}
    for i, v in ipairs(vfx_modes) do
        items[i] = { label = v.name, idx = i }
    end
    vim.ui.select(items, {
        prompt = "Pick cursor VFX mode",
        format_item = function(item)
            return (item.idx == vfx_idx and "> " or "  ") .. item.label
        end,
    }, function(choice)
        if not choice then return end
        vfx_idx = choice.idx
        vim.g.neovide_cursor_vfx_mode = vfx_modes[vfx_idx].mode
        vim.notify("VFX: " .. vfx_modes[vfx_idx].name)
    end)
end

local function random_vfx()
    vfx_idx = math.random(#vfx_modes)
    vim.g.neovide_cursor_vfx_mode = vfx_modes[vfx_idx].mode
    vim.notify("VFX: " .. vfx_modes[vfx_idx].name)
end

vim.keymap.set("n", "<leader>uv", function()
    vim.ui.select({
        { desc = "Next VFX mode",     action = "next" },
        { desc = "Previous VFX mode", action = "prev" },
        { desc = "Pick from list",    action = "list" },
        { desc = "Random VFX mode",   action = "random" },
    }, {
        prompt = "VFX: " .. (vim.g.neovide_cursor_vfx_mode or "none"),
        format_item = function(item) return item.desc end,
    }, function(choice)
        if not choice then return end
        if choice.action == "next" then switch_vfx(1)
        elseif choice.action == "prev" then switch_vfx(-1)
        elseif choice.action == "list" then select_vfx()
        elseif choice.action == "random" then random_vfx()
        end
    end)
end, { desc = "切换光标特效模式" })

