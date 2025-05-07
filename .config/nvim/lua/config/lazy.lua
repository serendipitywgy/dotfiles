-- 引导安装 lazy.nvim 插件管理器
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "无法克隆 lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\n按任意键退出..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- 确保在加载 lazy.nvim 之前设置 `mapleader` 和 `maplocalleader`
-- 这样可以确保按键映射正确生效
-- 这里也是设置其他基本配置(vim.opt)的好地方
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 设置 lazy.nvim
require("lazy").setup({
  spec = {
    -- 导入你的插件
    -- { import = "plugins" },
    { import = "plugins.ui" },
    { import = "plugins.lsp" },
    { import = "plugins.ai" },
  },
  -- 在这里配置其他设置。详情请参阅文档。
  -- 安装插件时使用的配色方案
  install = { colorscheme = { "habamax" } },
  -- 自动检查插件更新
  checker = { enabled = false },
})
