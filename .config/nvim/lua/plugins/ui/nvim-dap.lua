local function get_args()
	local args_string = vim.fn.input("Arguments: ")
	return vim.split(args_string, " +")
end

return {
	"mfussenegger/nvim-dap",
	recommended = true,
	desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",
	event = "VeryLazy",

	dependencies = {
		{
			"rcarriga/nvim-dap-ui",
			dependencies = {
				-- 添加 nvim-nio 依赖，这是 nvim-dap-ui 需要的
				"nvim-neotest/nvim-nio",
			},
		},
		-- virtual text for the debugger
		{
			"theHamsta/nvim-dap-virtual-text",
			opts = {},
		},
		-- 添加 plenary 依赖，用于 JSON 处理
		"nvim-lua/plenary.nvim",
		-- 如果你使用 mason-nvim-dap，需要添加这个依赖
		"jay-babu/mason-nvim-dap.nvim",
	},

  -- stylua: ignore
  keys = {
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
    { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
    { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
    { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
    { "<leader>dj", function() require("dap").down() end, desc = "Down" },
    { "<leader>dk", function() require("dap").up() end, desc = "Up" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
    { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
    { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
    { "<leader>ds", function() require("dap").session() end, desc = "Session" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
  },

	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		-- 检查 mason-nvim-dap 是否可用
		local has_mason_nvim_dap, mason_nvim_dap = pcall(require, "mason-nvim-dap")
		if has_mason_nvim_dap then
			mason_nvim_dap.setup({
				-- 这里可以添加你的 mason-nvim-dap 配置
				-- 例如：automatic_installation = true
				ensure_installed = { "codelldb" },
			})
		end

		vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

		-- 自定义 DAP 图标
		local dap_icons = {
			Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
			Breakpoint = " ",
			BreakpointCondition = " ",
			BreakpointRejected = { " ", "DiagnosticError" },
			LogPoint = ".>",
		}

		for name, sign in pairs(dap_icons) do
			sign = type(sign) == "table" and sign or { sign }
			vim.fn.sign_define(
				"Dap" .. name,
				{ text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
			)
		end

		-- setup dap config by VsCode launch.json file
		local vscode = require("dap.ext.vscode")
		local json = require("plenary.json")
		vscode.json_decode = function(str)
			return vim.json.decode(json.json_strip_comments(str))
		end

		-- 配置 DAP UI
		dapui.setup({
			icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
			mappings = {
				-- 使用鼠标
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				edit = "e",
				repl = "r",
				toggle = "t",
			},
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.25 },
						"breakpoints",
						"stacks",
						"watches",
					},
					size = 40, -- 列宽度
					position = "left",
				},
				{
					elements = {
						"repl",
						"console",
					},
					size = 0.25, -- 高度比例
					position = "bottom",
				},
			},
			floating = {
				max_height = nil,
				max_width = nil,
				border = "single",
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
		})

		-- 自动打开和关闭调试UI
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		-- 获取Mason安装的codelldb路径
		local mason_registry = require("mason-registry")

		if mason_registry.is_installed("codelldb") then
			local codelldb_package = mason_registry.get_package("codelldb")
			local codelldb_install_path = codelldb_package:get_install_path()

			-- Linux系统下的路径设置
			local codelldb_path = codelldb_install_path .. "/extension/adapter/codelldb"

			-- 确保codelldb可执行
			vim.fn.system("chmod +x " .. codelldb_path)

			-- 配置codelldb适配器
			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = codelldb_path,
					args = { "--port", "${port}" },
				},
			}

			-- 配置C++调试选项
			dap.configurations.cpp = {
				{
					name = "Launch file",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = function()
						local args_string = vim.fn.input("Program arguments: ")
						return vim.fn.split(args_string, " ", true)
					end,
					runInTerminal = false,
				},
				{
					name = "Attach to process",
					type = "codelldb",
					request = "attach",
					pid = require("dap.utils").pick_process,
					args = {},
				},
			}

			-- C语言使用相同的配置
			dap.configurations.c = dap.configurations.cpp
			-- Rust也可以使用相同的配置
			dap.configurations.rust = dap.configurations.cpp
		else
			vim.notify(
				"codelldb not found. Please install it with Mason first (:MasonInstall codelldb)",
				vim.log.levels.WARN
			)
		end
	end,
}
