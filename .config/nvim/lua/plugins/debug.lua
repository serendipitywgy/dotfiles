local M = {}

local initialized = false

function M.ensure()
    if initialized then return require("dap") end

    require("plugins.overseer").ensure()
    vim.cmd.packadd("nvim-nio")
    vim.cmd.packadd("nvim-dap")
    vim.cmd.packadd("nvim-dap-ui")
    vim.cmd.packadd("nvim-dap-virtual-text")
    vim.cmd.packadd("nvim-dap-python")

    require("config.debugging").setup()
    require("plugins.overseer").enable_dap()
    require("plugins.cmake").register_dap()
    initialized = true
    return require("dap")
end

local function dap_action(name)
    return function()
        local dap = M.ensure()
        dap[name]()
    end
end

local function dapui_toggle()
    M.ensure()
    require("dapui").toggle({ reset = true })
end

vim.keymap.set("n", "<leader>du", dapui_toggle, { desc = "DAP: 切换界面" })
vim.keymap.set("n", "<F1>", dapui_toggle, { desc = "DAP: 切换界面" })
vim.keymap.set("n", "<leader>ds", dap_action("continue"), { desc = "开始/继续" })
vim.keymap.set("n", "<F2>", dap_action("continue"), { desc = "开始/继续" })
vim.keymap.set("n", "<leader>di", dap_action("step_into"), { desc = "步入" })
vim.keymap.set("n", "<F3>", dap_action("step_into"), { desc = "步入" })
vim.keymap.set("n", "<leader>do", dap_action("step_over"), { desc = "步过" })
vim.keymap.set("n", "<F4>", dap_action("step_over"), { desc = "步过" })
vim.keymap.set("n", "<leader>dO", dap_action("step_out"), { desc = "步出" })
vim.keymap.set("n", "<F5>", dap_action("step_out"), { desc = "步出" })
vim.keymap.set("n", "<leader>dq", dap_action("close"), { desc = "DAP: 关闭会话" })
vim.keymap.set("n", "<leader>dr", dap_action("restart_frame"), { desc = "DAP: 重启帧" })
vim.keymap.set("n", "<F6>", dap_action("restart"), { desc = "DAP: 重新开始" })
vim.keymap.set("n", "<leader>dQ", dap_action("terminate"), { desc = "终止会话" })
vim.keymap.set("n", "<F7>", dap_action("terminate"), { desc = "终止会话" })
vim.keymap.set("n", "<leader>dc", dap_action("run_to_cursor"), { desc = "DAP: 运行到光标" })
vim.keymap.set("n", "<leader>dR", function()
    M.ensure().repl.toggle()
end, { desc = "DAP: 切换 REPL" })
vim.keymap.set("n", "<leader>dh", function()
    M.ensure()
    require("dap.ui.widgets").hover()
end, { desc = "DAP: 悬停查看" })
vim.keymap.set("n", "<leader>db", dap_action("toggle_breakpoint"), { desc = "DAP: 断点" })
vim.keymap.set("n", "<leader>dB", function()
    local condition = vim.fn.input("Condition for breakpoint: ")
    M.ensure().set_breakpoint(condition)
end, { desc = "DAP: 条件断点" })
vim.keymap.set("n", "<leader>dD", dap_action("clear_breakpoints"), { desc = "DAP: 清除断点" })

return M
