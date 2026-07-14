vim.g.mapleader = " "

-- PackUtils 引擎 + 集中插件下载 + 自动加载所有插件配置
require("pack")

require("config.options")
require("config.keymaps")
require("config.build")
require("config.autocmds")
require("config.neovide")
require("config.theme")
