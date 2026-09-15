vim.g.mapleader = " "
vim.g.codeium_disable_bindings = 1

-- 原生 vim.pack 插件管理与显式配置加载
require("pack")

require("config.options")
require("config.keymaps")
require("config.build")
require("config.autocmds")
require("config.theme")
