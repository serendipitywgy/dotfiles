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
        -- cmake-tools 的 DirChanged 会保存旧项目并恢复新项目的会话。
        if normalize(vim.uv.cwd()) ~= root then
            vim.api.nvim_set_current_dir(root)
        end
        project_root = root
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

-- preset 决定构建类型，旧会话中的命令行覆盖不能凌驾于它之上。
function M.prepare_preset(cmake)
    if not cmake.has_cmake_preset() then return end
    local options = cmake.get_generate_options()
    local keys = vim.tbl_keys(options)
    table.sort(keys)
    local filtered = {}
    local skip = false
    for _, key in ipairs(keys) do
        local option = options[key]
        if skip then
            skip = false
        elseif option == "-D" and type(options[key + 1]) == "string"
            and options[key + 1]:match("^CMAKE_BUILD_TYPE[:=]") then
            skip = true
        elseif not option:match("^%-DCMAKE_BUILD_TYPE[:=]") then
            filtered[#filtered + 1] = option
        end
    end
    for key in pairs(options) do options[key] = nil end
    vim.list_extend(options, filtered)
end

function M.select(cmake, on_success)
    if not cmake.has_cmake_preset() then
        return cmake.select_build_type(function(result)
            if result:is_ok() and on_success then on_success() end
        end)
    end

    M.prepare_preset(cmake)
    local presets = require("cmake-tools.presets"):parse(project_root)
    local callback = function(result)
        if result:is_ok() and on_success then on_success() end
    end
    -- build preset 自带 configurePreset，插件会一次同步两者。
    if #presets:get_build_preset_names({ include_disabled = true }) > 0 then
        cmake.select_build_preset(callback)
    else
        cmake.select_configure_preset(callback)
    end
end

return M
