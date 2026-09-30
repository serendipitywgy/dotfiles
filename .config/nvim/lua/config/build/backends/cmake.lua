local M = { name = "CMake" }

local conan_build_types = {}

local function root(path, markers)
    return vim.fs.root(path, markers)
end

local function is_ancestor(parent, child)
    parent = vim.fs.normalize(parent):gsub("/$", "")
    child = vim.fs.normalize(child):gsub("/$", "")
    return child == parent or vim.startswith(child, parent .. "/")
end

function M.detect(ctx)
    local conan_root = root(ctx.path, { "conanfile.py", "conanfile.txt" })
    local boundary = conan_root or root(ctx.path, { "CMakePresets.json", "CMakeUserPresets.json" })
        or root(ctx.path, { ".git" })
    local cmake_root = boundary and vim.uv.fs_stat(boundary .. "/CMakeLists.txt") and boundary
        or root(ctx.path, { "CMakeLists.txt", "CMakePresets.json", "CMakeUserPresets.json" })
    if not cmake_root then return nil end

    if conan_root and not is_ancestor(conan_root, cmake_root) then conan_root = nil end
    return { root = cmake_root, conan_root = conan_root }
end

local function conan_presets_valid(ctx)
    if not ctx.conan_root then return true end

    local path = ctx.conan_root .. "/CMakeUserPresets.json"
    if not vim.uv.fs_stat(path) then return false end
    local lines = vim.fn.readfile(path)
    if vim.tbl_isempty(lines) then return false end

    local ok, data = pcall(vim.json.decode, table.concat(lines, "\n"))
    if not ok or type(data) ~= "table" or type(data.include) ~= "table" then return false end
    local build_type = conan_build_types[ctx.root]
    for _, include in ipairs(data.include) do
        local included = ctx.conan_root .. "/" .. include
        if vim.uv.fs_stat(included) then
            if not build_type then return true end
            local decoded, presets = pcall(vim.json.decode, table.concat(vim.fn.readfile(included), "\n"))
            if decoded and type(presets) == "table" then
                for _, preset in ipairs(presets.configurePresets or {}) do
                    if (preset.cacheVariables or {}).CMAKE_BUILD_TYPE == build_type then return true end
                end
            end
        end
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

    local build_type = conan_build_types[ctx.root] or "Debug"
    local profile = build_type == "Debug" and "debug" or "default"
    local task = overseer.new_task({
        name = "Conan install (" .. build_type .. ")",
        cmd = { "conan" },
        args = { "install", ".", "-pr:h=" .. profile, "-pr:b=" .. profile, "-s:h", "build_type=" .. build_type },
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
        local plugin = require("plugins.cmake")
        local cmake = plugin.ensure(ctx.root)
        if not cmake then return end
        local function generate()
            plugin.prepare_preset(cmake)
            if ctx.conan_root then conan_build_types[ctx.root] = cmake.get_build_type() end
            -- 每次重新配置，修复旧缓存，并在失败时阻止后续编译/运行。
            cmake.generate({ bang = false, fargs = {} }, function(result)
                if result:is_ok() and command ~= "CMakeGenerate" then vim.cmd(command) end
            end)
        end
        if cmake.has_cmake_preset() and not cmake.get_build_preset() and not cmake.get_configure_preset() then
            plugin.select(cmake, generate)
        else
            generate()
        end
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
        if conan_presets_valid(ctx) then
            local cmake = require("plugins.cmake").ensure(ctx.root)
            if cmake then conan_build_types[ctx.root] = cmake.get_build_type() end
        end
        conan_install(ctx, function()
            run_cmake(ctx, "CMakeGenerate", false)
        end)
    else
        run_cmake(ctx, "CMakeGenerate", false)
    end
end

function M.select(ctx)
    if ctx.conan_root and not conan_presets_valid(ctx) then
        vim.ui.select({ "Debug", "Release" }, { prompt = "选择 Conan 构建类型" }, function(choice)
            if not choice then return end
            conan_build_types[ctx.root] = choice
            conan_install(ctx, function()
                local plugin = require("plugins.cmake")
                local cmake = plugin.ensure(ctx.root)
                if cmake then plugin.select(cmake) end
            end)
        end)
        return
    end

    local plugin = require("plugins.cmake")
    local cmake = plugin.ensure(ctx.root)
    if not cmake then return end
    plugin.select(cmake, function()
        if ctx.conan_root then conan_build_types[ctx.root] = cmake.get_build_type() end
    end)
end

return M
