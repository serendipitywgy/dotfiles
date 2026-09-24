local M = { name = "CMake" }

local conan_build_type = "Debug"

local function root(path, markers)
    return vim.fs.root(path, markers)
end

local function is_ancestor(parent, child)
    parent = vim.fs.normalize(parent):gsub("/$", "")
    child = vim.fs.normalize(child):gsub("/$", "")
    return child == parent or vim.startswith(child, parent .. "/")
end

function M.detect(ctx)
    local cmake_root = root(ctx.path, { "CMakeLists.txt", "CMakePresets.json", "CMakeUserPresets.json" })
    if not cmake_root then return nil end

    local conan_root = root(ctx.path, { "conanfile.py", "conanfile.txt" })
    if conan_root and not is_ancestor(conan_root, cmake_root) then conan_root = nil end
    return { root = cmake_root, conan_root = conan_root }
end

local function preset_file_exists(project_root)
    return vim.uv.fs_stat(project_root .. "/CMakePresets.json") ~= nil
        or vim.uv.fs_stat(project_root .. "/cmake-presets.json") ~= nil
end

local function conan_presets_valid(ctx)
    if not ctx.conan_root then return true end

    local path = ctx.conan_root .. "/CMakeUserPresets.json"
    if not vim.uv.fs_stat(path) then return false end
    local lines = vim.fn.readfile(path)
    if vim.tbl_isempty(lines) then return false end

    local ok, data = pcall(vim.json.decode, table.concat(lines, "\n"))
    if not ok or type(data) ~= "table" or type(data.include) ~= "table" then return false end
    for _, include in ipairs(data.include) do
        if vim.uv.fs_stat(ctx.conan_root .. "/" .. include) then return true end
    end
    return false
end

local function conan_running(overseer, cwd)
    for _, task in ipairs(overseer.list_tasks({ status = overseer.STATUS.RUNNING })) do
        if task.cwd == cwd and vim.startswith(task.name, "Conan install") then return true end
    end
    return false
end

local function conan_install(ctx, on_success)
    local overseer = require("plugins.overseer").ensure()
    if conan_running(overseer, ctx.conan_root) then
        vim.notify("当前项目已有 Conan install 正在运行", vim.log.levels.WARN)
        return
    end

    local profile = conan_build_type == "Debug" and "debug" or "default"
    local task = overseer.new_task({
        name = "Conan install (" .. conan_build_type .. ")",
        cmd = { "conan" },
        args = { "install", ".", "-pr:h=" .. profile, "-pr:b=" .. profile },
        cwd = ctx.conan_root,
        components = { "default" },
    })
    task:subscribe("on_complete", function(_, status)
        if status == overseer.STATUS.SUCCESS and on_success then vim.schedule(on_success) end
    end)
    task:start()
    require("plugins.overseer").open()
end

local function run_cmake(ctx, command, needs_dap)
    local function run()
        if needs_dap then require("plugins.debug").ensure() end
        if not require("plugins.cmake").ensure(ctx.root) then return end
        vim.cmd(command)
    end

    if ctx.conan_root and not conan_presets_valid(ctx) then
        conan_install(ctx, run)
    else
        run()
    end
end

function M.build(ctx) run_cmake(ctx, "CMakeBuild", false) end
function M.run(ctx) run_cmake(ctx, "CMakeRun", false) end
function M.debug(ctx) run_cmake(ctx, "CMakeDebug", true) end

function M.configure(ctx)
    if ctx.conan_root then
        conan_install(ctx, function()
            if require("plugins.cmake").ensure(ctx.root) then vim.cmd("CMakeGenerate") end
        end)
    else
        run_cmake(ctx, "CMakeGenerate", false)
    end
end

function M.select(ctx)
    if ctx.conan_root and not conan_presets_valid(ctx) then
        vim.ui.select({ "Debug", "Release" }, { prompt = "选择 Conan 构建类型" }, function(choice)
            if not choice then return end
            conan_build_type = choice
            conan_install(ctx, function()
                if require("plugins.cmake").ensure(ctx.root) then vim.cmd("CMakeSelectBuildPreset") end
            end)
        end)
        return
    end

    if not require("plugins.cmake").ensure(ctx.root) then return end
    if preset_file_exists(ctx.root) or vim.uv.fs_stat(ctx.root .. "/CMakeUserPresets.json") then
        vim.cmd("CMakeSelectBuildPreset")
    else
        vim.cmd("CMakeSelectBuildType")
    end
end

return M
