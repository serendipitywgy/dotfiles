local M = {}
function M.setup()
	-- 定义与 toggleterm 相关的功能
	local Terminal = require("toggleterm.terminal").Terminal
	local fs = vim.fs

	-- 创建构建终端
	local function create_build_terminal(cmd, direction, float_opts)
		return Terminal:new({
			cmd = cmd,
			hidden = true,
			direction = direction,
			float_opts = float_opts,
			on_open = function(term)
				vim.cmd("startinsert!")
				vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
			end,
			on_close = function(_)
				vim.cmd("startinsert!")
			end,
		})
	end

	-- Conan 构建终端
	local conan_build = create_build_terminal("conan build . -pr:h=debug -pr:b=debug", "horizontal", {
		border = "double",
		width = 110,
	})
	-- QML 运行终端
	local qml_run = nil

	-- 创建 QML 运行终端的函数
	local function create_qml_run_terminal()
		local current_file = vim.fn.expand("%:p")
		if current_file:match("%.qml$") then
			qml_run = Terminal:new({
				cmd = "qml6 " .. current_file,
				hidden = true,
				direction = "vertical",
				float_opts = {
					border = "double",
					width = 110,
				},
				on_open = function(term)
					vim.cmd("startinsert!")
					vim.api.nvim_buf_set_keymap(
						term.bufnr,
						"n",
						"q",
						"<cmd>close<CR>",
						{ noremap = true, silent = true }
					)
				end,
				on_close = function(_)
					vim.cmd("startinsert!")
				end,
				on_exit = function(term, job_id, exit_code, event)
					if exit_code == 0 then
						term:close()
					end
				end,
			})
			qml_run:toggle() -- 确保终端被正确打开
		else
			print("当前文件不是 QML 文件")
		end
	end

	--智能构建函数
	function _G.smart_build()
		vim.cmd("wa")
		local cwd = vim.fn.getcwd()
		local has_conanfile = fs.find("conanfile.py", { path = cwd, upward = true, type = "file" })[1] ~= nil
		local has_cmakelist = fs.find("CMakeLists.txt", { path = cwd, upward = true, type = "file" })[1] ~= nil

		if has_conanfile then
			conan_build:toggle()
		elseif has_cmakelist then
			vim.cmd("CMakeRun")
		else
			create_qml_run_terminal()
		end
	end

	-- 设置多模式键映射
	local function set_keymap_multi_mode(modes, lhs, rhs, opts)
		for _, mode in ipairs(modes) do
			vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
		end
	end

	-- 设置键映射
	set_keymap_multi_mode({ "n", "i", "t" }, "<F4>", "<cmd>lua smart_build()<CR>", { noremap = true, silent = true })
end
-- 在模块加载时自动调用 setup 函数
M.setup()
return M
