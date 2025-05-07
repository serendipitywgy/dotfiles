vim.g.mapleader = " "
vim.g.autoformat = true

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

vim.opt.clipboard = "unnamedplus" -- 设置剪贴板选项

opt.spell = false -- 禁止使用拼写检查

-- 显示空白字符
-- opt.list = true
-- opt.listchars = { space = "·" }

opt.number = true
opt.relativenumber = true
opt.autoindent = true

opt.wrap = true -- 启用自动换行
opt.colorcolumn = "150" -- 在第81列显示垂直线，用于提示代码宽度
opt.cursorline = true -- 高亮当前行
opt.ignorecase = true -- 搜索时忽略大小写
opt.smartcase = true -- 如果搜索包含大写字母，则变为大小写敏感
-- opt.hlsearch = false
opt.foldlevel = 99 -- 设置折叠级别
opt.foldenable = false -- 默认不启用代码折叠

opt.expandtab = true -- 将制表符展开为空格
opt.softtabstop = 4 -- 软制表符宽度为4
opt.shiftwidth = 4 -- 自动缩进宽度为4
opt.tabstop = 4 -- 制表符宽度为4
opt.cindent = true -- 启用C语言样式缩进
opt.cino = "(0,W4" -- 设置C语言缩进选项

opt.splitbelow = true -- 新窗口在下方
opt.splitright = true -- 新窗口在右边

opt.undofile = true --启用了 Neovim 的持久化撤销历史功能

-- ' 清空背景色，支持透明背景
-- autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE
-- vim.filetype.add({
--   extension = {
--     qss = "css",
--     ts = "xml",
--     ui = "xml",
--     qrc = "xml",
--   },
-- })
--
-- vim.g.autoformat = false  -- 这一行是全局禁止格式化
-- 为cpp文件设置禁止自动格式化
vim.api.nvim_create_autocmd("FileType", {
  pattern = "cpp",
  callback = function()
    vim.b.autoformat = false
  end,
})
vim.g.snacks_animate = false
