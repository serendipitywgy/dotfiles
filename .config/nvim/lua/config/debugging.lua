local M = {}

local initialized = false

function M.setup()
    if initialized then return end

    local dap = require("dap")
    local dapui = require("dapui")
    local codelldb = vim.fn.exepath("codelldb")
    if codelldb == "" then codelldb = vim.fn.expand("~/.local/bin/codelldb") end

    dap.adapters.codelldb = {
        type = "executable",
        command = codelldb,
    }
    dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    }

    local function executable()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end

    dap.configurations.cpp = {
        {
            name = "Launch (CodeLLDB)",
            type = "codelldb",
            request = "launch",
            program = executable,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
        {
            name = "Launch (GDB DAP)",
            type = "gdb",
            request = "launch",
            program = executable,
            cwd = "${workspaceFolder}",
            stopAtBeginningOfMainSubprogram = false,
        },
        {
            name = "Attach (CodeLLDB)",
            type = "codelldb",
            request = "attach",
            pid = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
        },
    }
    dap.configurations.c = dap.configurations.cpp

    require("dap-python").setup("uv", { include_configs = false })
    dap.configurations.python = {
        {
            name = "Launch current file",
            type = "python",
            request = "launch",
            program = "${file}",
            console = "integratedTerminal",
            cwd = function() return vim.fn.getcwd() end,
            args = function()
                local input = vim.fn.input("Arguments: ")
                if input == "" then return {} end
                return require("dap.utils").splitstr(input)
            end,
        },
    }

    require("nvim-dap-virtual-text").setup()
    dapui.setup({
        expand_lines = false,
        layouts = {
            {
                position = "left",
                size = 0.2,
                elements = {
                    { id = "stacks", size = 0.2 },
                    { id = "scopes", size = 0.5 },
                    { id = "breakpoints", size = 0.15 },
                    { id = "watches", size = 0.15 },
                },
            },
            {
                position = "bottom",
                size = 0.2,
                elements = {
                    { id = "repl", size = 0.3 },
                    { id = "console", size = 0.7 },
                },
            },
        },
    })

    local function open_ui()
        if package.loaded.overseer then require("overseer").close() end
        dapui.open({ reset = true })
    end
    dap.listeners.before.attach.dapui_config = open_ui
    dap.listeners.before.launch.dapui_config = open_ui
    dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
    dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

    vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = "DapBreakpoint",
    })
    vim.fn.sign_define("DapBreakpointCondition", {
        text = "",
        texthl = "DapBreakpointCondition",
        linehl = "DapBreakpointCondition",
        numhl = "DapBreakpointCondition",
    })
    vim.fn.sign_define("DapStopped", {
        text = "",
        texthl = "DapStopped",
        linehl = "DapStopped",
        numhl = "DapStopped",
    })

    initialized = true
end

return M
