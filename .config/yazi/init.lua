-- ~/.config/yazi/init.lua
-- full-border / git / zoxide（zoxide 为内置插件）

require("full-border"):setup({
	type = ui.Border.ROUNDED,
})

require("git"):setup({
	order = 1500,
})

-- 在 Yazi 里进出的目录写入 zoxide 数据库（默认 z 键跳转）
require("zoxide"):setup({
	update_db = true,
})
