local M = {}

local initialized = false
local dap_registered = false
local project_root

local function normalize(path)
    return vim.fs.normalize(vim.fn.fnamemodify(path, ":p")):gsub("/$", "")
end

function M.ensure(root)
    root = normalize(root)
    if initialized then
        if project_root ~= root then
            vim.notify(
                "cmake-tools 已绑定到 " .. project_root .. "，请为另一个项目启动新的 Neovim 实例",
                vim.log.levels.ERROR
            )
            return nil
        end
        return require("cmake-tools")
    end

    require("plugins.overseer").ensure()
    vim.cmd.packadd("plenary.nvim")
    vim.cmd.packadd("cmake-tools.nvim")

    if normalize(vim.uv.cwd()) ~= root then
        vim.api.nvim_set_current_dir(root)
    end

    local cmake = require("cmake-tools")
    cmake.setup({
        cmake_command = "cmake",
        cmake_build_directory = "build",
        cmake_build_options = {},
        cmake_roll_forward = false,
        cmake_variantsfile = "CMakeLists.txt.user",
        cmake_executor = {
            name = "overseer",
            opts = {
                new_task_opts = {
                    components = {
                        {
                            "on_output_quickfix",
                            items_only = true,
                            open_on_match = true,
                            open_on_exit = "failure",
                        },
                        "default",
                    },
                },
                on_new_task = function()
                    require("plugins.overseer").open()
                end,
            },
        },
        cmake_runner = {
            name = "overseer",
            opts = {
                on_new_task = function()
                    require("plugins.overseer").open()
                end,
            },
        },
        cmake_dap_configuration = {
            name = "CMake target",
            type = "codelldb",
            request = "launch",
            stopOnEntry = false,
            runInTerminal = true,
        },
        cmake_dap_debugger = "codelldb",
        cmake_notify_cmake_file_modified = false,
    })

    project_root = root
    initialized = true
    dap_registered = package.loaded.dap ~= nil
    return cmake
end

function M.register_dap()
    if initialized and not dap_registered then
        require("cmake-tools").register_dap_function()
        dap_registered = true
    end
end

function M.root()
    return project_root
end

return M
