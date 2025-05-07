return {
	"akinsho/toggleterm.nvim",
	version = "*", -- 使用最新稳定版本
	config = function()
		require("toggleterm").setup({
			size = function(term)
				if term.direction == "horizontal" then
					return 10
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.2
				end
			end,
			open_mapping = [[<C-t>]],
			hide_numbers = true, -- 隐藏 toggleterm 缓冲区中的行号列
			autochdir = true, -- 自动切换目录
			shade_terminals = false, -- 禁用终端窗口的阴影效果
			start_in_insert = true, -- 启动时进入插入模式
			insert_mappings = true, -- 是否在插入模式下应用打开映射
			terminal_mappings = true, -- 是否在打开的终端中应用打开映射
			persist_size = true, -- 持久化终端大小
			persist_mode = true, -- 持久化终端模式
			direction = "tab", -- 终端方向
			close_on_exit = false, -- 进程退出时关闭终端窗口
			auto_scroll = false, -- 自动滚动到终端输出的底部
			float_opts = {
				border = "curved", -- 浮动终端的边框样式
				width = 70, -- 浮动终端的宽度
				height = 18, -- 浮动终端的高度
				-- winblend = 0, -- 浮动终端的透明度 --这一行不需要，不用的话，旧跟自带终端保持一致
			},
			highlights = {
				Normal = {
					guibg = "none", -- 正常终端背景颜色
				},
				NormalFloat = {
					link = "Normal", -- 浮动终端背景颜色链接到正常终端
				},
				FloatBorder = {
					guibg = "none", -- 浮动终端边框背景颜色
				},
			},
			winbar = {
				enabled = false, -- 禁用窗口栏
				name_formatter = function(term) -- 终端名称格式化函数
					return term.name
				end,
			},
		})
	end,
}

  --************************ 上面是配置 toggleterm 插件 *******************************

