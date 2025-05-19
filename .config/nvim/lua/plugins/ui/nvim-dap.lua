local function get_args()
    local args_string = vim.fn.input("Arguments: ")
    return vim.split(args_string, " +")
end

return {
    {
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
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" }, --条件断点
            { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },    --添加/删除断点
            { "<leader>dc", function() require("dap").continue() end,                                             desc = "Run/Continue" },
            { "<leader>da", function() require("dap").continue({ before = get_args }) end,                        desc = "Run with Args" },
            { "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
            { "<leader>dg", function() require("dap").goto_() end,                                                desc = "Go to Line (No Execute)" },
            { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
            { "<leader>dj", function() require("dap").down() end,                                                 desc = "Down" },
            { "<leader>dk", function() require("dap").up() end,                                                   desc = "Up" },
            { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
            { "<leader>do", function() require("dap").step_out() end,                                             desc = "Step Out" },
            { "<leader>dO", function() require("dap").step_over() end,                                            desc = "Step Over" },
            { "<leader>dP", function() require("dap").pause() end,                                                desc = "Pause" },
            { "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
            { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
            { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
            { "<leader>dw", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },
        },

        config = function()
            vim.api.nvim_set_hl(0, "DapStopped", {
                ctermbg = 0,
                fg = "#98c379",
                bg = "#31353f",
            })
            vim.fn.sign_define(
                "DapStopped",
                { text = "", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" }
            )
            vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "", linehl = "", numhl = "" })
            vim.fn.sign_define("DapLogPoint", { text = "", texthl = "", linehl = "", numhl = "" })

            local dap = require("dap")
            dap.adapters.gdb = {
                type = "executable",
                command = "gdb",
                args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
            }
            dap.adapters.cppdbg = {
                id = "cppdbg",
                type = "executable",
                command = "/usr/share/cpptools-debug/bin/OpenDebugAD7",
            }


            -- 提取获取可执行程序的公共函数
            local function get_program_path()
                local function is_executable(path)
                    return vim.fn.executable(path) == 1
                end

                local function find_executables(dir)
                    local handle = vim.loop.fs_scandir(dir)
                    if not handle then
                        return {}
                    end

                    local executables = {}
                    while true do
                        local name, type = vim.loop.fs_scandir_next(handle)
                        if not name then
                            break
                        end

                        local path = dir .. "/" .. name
                        if type == "file" and is_executable(path) then
                            table.insert(executables, path)
                        end
                    end
                    return executables
                end

                -- local debug_dir = vim.fn.getcwd() .. "/build/Debug/install/bin"
                -- local release_dir = vim.fn.getcwd() .. "/build/Release/install/bin"

                local debug_dir = vim.fn.getcwd() .. "/build/Debug"
                local release_dir = vim.fn.getcwd() .. "/build/Release"
                -- 合并 Debug 和 Release 目录下的可执行文件
                local executables = {}
                vim.list_extend(executables, find_executables(debug_dir))
                vim.list_extend(executables, find_executables(release_dir))

                if #executables == 0 then
                    vim.notify("No executable files found in build directory", vim.log.levels.WARN)
                    return nil
                end

                return coroutine.create(function(dap_run_co)
                    vim.ui.select(executables, {
                        prompt = "选择要调试的程序: ",
                    }, function(choice)
                        coroutine.resume(dap_run_co, choice)
                    end)
                end)
            end
            -- 获取Mason安装的codelldb路径
            local InstallLocation = require "mason-core.installer.InstallLocation"
            local mason_registry = require("mason-registry")
            local codelldb_path = ""
            if mason_registry.is_installed("codelldb") then
                -- local codelldb_package = mason_registry.get_package("codelldb")
                local codelldb_install_path = InstallLocation.global():package('codelldb')
                codelldb_path = codelldb_install_path .. "/extension/adapter/codelldb"
            end
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
            dap.configurations.cpp = {
                {
                    name = "Launch (codelldb)",
                    type = "codelldb",
                    request = "launch",
                    args = function()
                        local args_string = vim.fn.input("Arguments: ")
                        return vim.split(args_string, " ", { trimempty = true })
                    end,
                    program = function()
                        return get_program_path()
                    end,
                    cwd = "${workspaceFolder}",
                    stopAtEntry = true,
                    setupCommands = {
                        {
                            text = "-enable-pretty-printing",
                            description = "enable pretty printing",
                            ignoreFailures = false,
                        },
                    },
                },
                {
                    name = "Launch (vscode-cpptools)",
                    type = "cppdbg",
                    request = "launch",
                    args = function()
                        local args_string = vim.fn.input("Arguments: ")
                        return vim.split(args_string, " ", { trimempty = true })
                    end,
                    program = function()
                        return get_program_path()
                    end,
                    cwd = "${workspaceFolder}",
                    stopAtEntry = true,
                    setupCommands = {
                        {
                            text = "-enable-pretty-printing",
                            description = "enable pretty printing",
                            ignoreFailures = false,
                        },
                    },
                },
                {
                    name = "Select and attach to process (vscode-cpptools)",
                    type = "cppdbg",
                    request = "attach",
                    program = function()
                        return get_program_path()
                    end,
                    pid = function()
                        local name = vim.fn.input("Executable name (filter): ")
                        return require("dap.utils").pick_process({ filter = name })
                    end,
                    cwd = "${workspaceFolder}",
                    setupCommands = {
                        {
                            text = "-enable-pretty-printing",
                            description = "enable pretty printing",
                            ignoreFailures = false,
                        },
                    },
                },
                {
                    name = "Attach to gdbserver :1234 (vscode-cpptools)",
                    type = "cppdbg",
                    request = "launch",
                    MIMode = "gdb",
                    miDebuggerServerAddress = "localhost:1234",
                    miDebuggerPath = "/usr/bin/gdb",
                    cwd = "${workspaceFolder}",
                    setupCommands = {
                        {
                            text = "-enable-pretty-printing",
                            description = "enable pretty printing",
                            ignoreFailures = false,
                        },
                    },
                },
                {
                    name = "Launch (gdb)",
                    type = "gdb",
                    request = "launch",
                    args = function()
                        local args_string = vim.fn.input("Arguments: ")
                        return vim.split(args_string, " ", { trimempty = true })
                    end,
                    program = function()
                        return get_program_path()
                    end,
                    cwd = "${workspaceFolder}",
                    stopAtBeginningOfMainSubprogram = false,
                },
                {
                    name = "Select and attach to process (gdb)",
                    type = "gdb",
                    request = "attach",
                    pid = function()
                        local name = vim.fn.input("Executable name (filter): ")
                        return require("dap.utils").pick_process({ filter = name })
                    end,
                    cwd = "${workspaceFolder}",
                },
                {
                    name = "Attach to gdbserver :1234 (gdb)",
                    type = "gdb",
                    request = "attach",
                    target = "localhost:1234",
                    cwd = "${workspaceFolder}",
                },
            }
            dap.configurations.c = dap.configurations.cpp
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        keys = {
            { "<leader>du", function() require("dapui").toggle({}) end,  desc = "Dap UI" },
            { "<leader>de", function() require("dapui").eval() end,      desc = "Eval",  mode = { "n", "v" } },
        },
        opts = {
            -- layouts = {
            --     {
            --         elements = {
            --             {
            --                 id = "repl",
            --                 size = 0.25,
            --             },
            --             {
            --                 id = "stacks",
            --                 size = 0.25,
            --             },
            --             {
            --                 id = "watches",
            --                 size = 0.25,
            --             },
            --             {
            --                 id = "scopes",
            --                 size = 0.25,
            --             },
            --         },
            --         position = "right",
            --         size = 80,
            --     },
            --     {
            --         elements = {
            --             {
            --                 id = "console",
            --                 size = 1,
            --             },
            --         },
            --         position = "bottom",
            --         size = 20,
            --     },
            -- },
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
            mappings = {
                -- 使用鼠标
                expand = { "<CR>", "<2-LeftMouse>" },
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r",
                toggle = "t",
            },
            icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        },
        config = function(_, opts)
            local dapui = require("dapui")
            dapui.setup(opts)

            local dap = require("dap")
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end
        end,
    },
    -- {
    --     "jay-babu/mason-nvim-dap.nvim",
    --     dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    --     opts = {
    --         ensure_installed = { "cpptools" },
    --     },
    -- },
}
