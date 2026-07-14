-- 统一构建模块：检测项目类型，路由到 cmake-tools 或 conan/overseer
local M = {}

-- 当前构建类型（Debug/Release），Conan 项目用
M.build_type = "Debug"

function M.is_conan()
    return vim.fn.filereadable("conanfile.py") == 1
end

function M.is_cmake()
    return vim.fn.filereadable("CMakeLists.txt") == 1
end

-- ============================================================
-- Conan 构建
-- ============================================================

local function conan_build()
    local args = { "conan", "build", "." }
    if M.build_type == "Debug" then
        table.insert(args, "-pr:h=debug")
        table.insert(args, "-pr:b=debug")
    end
    local overseer = require("overseer")
    local task = overseer.new_task({
        name = "conan build (" .. M.build_type .. ")",
        cmd = args,
        cwd = vim.fn.getcwd(),
    })
    task:start()
    overseer.open({ enter = false, direction = "bottom" })
end

local function conan_install()
    local args = { "conan", "install", "." }
    if M.build_type == "Debug" then
        table.insert(args, "-pr:h=debug")
        table.insert(args, "-pr:b=debug")
    end
    local overseer = require("overseer")
    local task = overseer.new_task({
        name = "conan install (" .. M.build_type .. ")",
        cmd = args,
        cwd = vim.fn.getcwd(),
    })
    task:start()
    overseer.open({ enter = false, direction = "bottom" })
end

local function conan_select_build_type()
    vim.ui.select({ "Release", "Debug" }, {
        prompt = "选择构建类型",
        format_item = function(item) return item end,
    }, function(choice)
        if choice then
            M.build_type = choice
            vim.notify("构建类型: " .. choice, vim.log.levels.INFO)
        end
    end)
end

local function conan_find_executable()
    local build_dir = vim.fn.getcwd() .. "/build"
    local type_dir = build_dir .. "/" .. M.build_type
    local files = vim.fn.glob(type_dir .. "/*", false, true)
    for _, f in ipairs(files) do
        local stat = vim.loop.fs_stat(f)
        if stat and stat.type == "file" then
            if vim.fn.getfperm(f):match("x") then
                return f
            end
        end
    end
    return nil
end

local function conan_run()
    local exe = conan_find_executable()
    if not exe then
        vim.notify("未找到可执行文件，请先构建", vim.log.levels.WARN)
        return
    end
    vim.cmd("split")
    vim.fn.termopen(exe)
    vim.cmd("startinsert")
end

local function conan_debug()
    local exe = conan_find_executable()
    if not exe then
        vim.notify("未找到可执行文件，请先构建", vim.log.levels.WARN)
        return
    end
    local dap = require("dap")
    dap.run({
        type = "codelldb",
        request = "launch",
        program = exe,
        cwd = vim.fn.getcwd(),
        stopOnEntry = false,
    })
end

-- ============================================================
-- CMake 构建（调用 cmake-tools）
-- ============================================================

local function cmake_build()
    vim.cmd("CMakeBuild")
end

local function cmake_build_type()
    vim.cmd("CMakeSelectBuildType")
end

local function cmake_configure()
    vim.cmd("CMakeGenerate")
end

local function cmake_run()
    vim.cmd("CMakeRun")
end

local function cmake_debug()
    vim.cmd("CMakeQuickRun")
end

local function cmake_open_output()
    vim.cmd("CMakeOpenExecutor")
end

-- ============================================================
-- 统一接口
-- ============================================================

function M.build()
    if M.is_conan() then
        conan_build()
    else
        cmake_build()
    end
end

function M.select_build_type()
    if M.is_conan() then
        conan_select_build_type()
    else
        cmake_build_type()
    end
end

function M.configure()
    if M.is_conan() then
        conan_install()
    else
        cmake_configure()
    end
end

function M.run()
    if M.is_conan() then
        conan_run()
    else
        cmake_run()
    end
end

function M.debug()
    if M.is_conan() then
        conan_debug()
    else
        cmake_debug()
    end
end

function M.open_output()
    if M.is_conan() then
        require("overseer").open({ enter = false, direction = "bottom" })
    else
        cmake_open_output()
    end
end

-- ============================================================
-- 快捷键
-- ============================================================

local function set_keymaps(mode, keymaps, target, opts)
    for _, keymap in ipairs(keymaps) do
        vim.keymap.set(mode, keymap, target, opts)
    end
end

set_keymaps("n", { "<leader>cb" }, M.build, { desc = "构建" })
set_keymaps("n", { "<leader>ct" }, M.select_build_type, { desc = "选择构建类型" })
set_keymaps("n", { "<leader>cg" }, M.configure, { desc = "配置" })
set_keymaps("n", { "<leader>co" }, M.open_output, { desc = "打开输出面板" })
set_keymaps("n", { "<leader>cr" }, M.run, { desc = "构建并运行" })
set_keymaps("n", { "<leader>cD" }, M.debug, { desc = "构建并调试" })

return M
