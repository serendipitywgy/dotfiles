local M = {}

-- 默认配置项，可通过 setup 函数覆盖
local default_config = {
    build = {
        conan_build_cmd = "conan build . -pr:h=debug -pr:b=debug",
        terminal_opts = {
            hidden = true,
            direction = "horizontal",
            float_opts = {
                border = "double",
                width = 110,
            }
        }
    },
    run = {
        terminal_opts = {
            hidden = false,
            direction = "float",
            float_opts = {
                border = "double",
                width = 110,
            }
        }
    },
    qml = {
        terminal_opts = {
            hidden = true,
            direction = "vertical",
            float_opts = {
                border = "double",
                width = 110,
            }
        }
    }
}

-- 终端实例管理
local terminals = {
    conan_build = nil,
    run_term = nil,
    qml_run = nil,
    is_building = false -- 新增构建状态标志
}

--- 注册快捷键
local function _register_keymaps()
    local function set_keymap_multi_mode(modes, lhs, rhs, opts)
        for _, mode in ipairs(modes) do
            vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
        end
    end

    set_keymap_multi_mode({ "n", "i", "t" }, "<F4>", "<cmd>lua require('plugins.utils.run').smart_build()<CR>",
        { noremap = true, silent = true })
    set_keymap_multi_mode({ "n", "i", "t" }, "<F5>", "<cmd>lua require('plugins.utils.run').run_executable()<CR>",
        { noremap = true, silent = true })
end

-- 配置缓存
local config = {}

--- 初始化模块配置
-- @param user_config 用户自定义配置，可选
function M.setup(user_config)
    config = vim.tbl_deep_extend("force", default_config, user_config or {})
    _register_keymaps()
end

--- 创建并配置终端实例
-- @param cmd 要执行的命令
-- @param terminal_type 终端类型 (build/run/qml)
-- @param on_exit_callback 退出时的回调函数，可选
-- @return Terminal 实例
local function _create_terminal(cmd, terminal_type, on_exit_callback)
    local Terminal = require("toggleterm.terminal").Terminal
    local terminal_opts = vim.deepcopy(config[terminal_type].terminal_opts)
    terminal_opts.cmd = cmd

    terminal_opts.on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(
            term.bufnr, "n", "q", "<cmd>close<CR>",
            { noremap = true, silent = true }
        )
    end

    terminal_opts.on_close = function(term)
        vim.cmd("startinsert!")
        if terminal_type == "build" then
            terminals.build_completed = false -- 终端被手动关闭后重置状态
        end
    end

    if on_exit_callback then
        terminal_opts.on_exit = function(term, job_id, exit_code, event)
            if terminal_type == "build" then
                terminals.build_completed = true -- 构建自然结束时设置完成标志
            end
            on_exit_callback(term, job_id, exit_code, event)
        end
    end

    return Terminal:new(terminal_opts)
end

--- 在项目目录中查找可执行文件
-- @param preferred_path string|nil 优先尝试的路径
-- @return string|nil, string 可执行文件路径和构建类型（Debug/Release/""）
local function _find_executable(preferred_path)
    -- 如果提供了优先路径且有效，直接返回
    if preferred_path and vim.fn.filereadable(preferred_path) == 1 then
        return preferred_path, "custom"
    end

    local cwd = vim.fn.getcwd()
    local search_patterns = {
        { path = vim.fs.joinpath(cwd, "build", "Debug", "bin"), type = "Debug" },
        { path = vim.fs.joinpath(cwd, "build", "Release", "bin"), type = "Release" },
        { path = vim.fs.joinpath(cwd, "build"), type = "" },
        { path = cwd, type = "" } -- 最后尝试当前目录
    }

    for _, pattern in ipairs(search_patterns) do
        if vim.fn.isdirectory(pattern.path) == 1 then
            local executables = vim.fs.find(function(name, path)
                -- 排除可能的临时文件和非可执行文件
                local is_executable = name:match("%.exe$") or
                    (vim.fn.executable(path) == 1 and
                        not name:match("%.o$") and
                        not name:match("%.a$") and
                        not name:match("%.so$") and
                        not name:match("%.dll$"))
                return is_executable
            end, { path = pattern.path, type = "file", limit = 1 }) -- 只找一个

            if #executables > 0 then
                return executables[1], pattern.type
            end
        end
    end

    return nil, ""
end

--- 创建 QML 运行终端
local function _create_qml_run_terminal()
    local current_file = vim.fn.expand("%:p")
    if not current_file:match("%.qml$") then
        vim.notify("当前文件不是 QML 文件", vim.log.levels.WARN)
        return
    end

    terminals.qml_run = _create_terminal(
        "qml6 " .. current_file,
        "qml"
    )
    terminals.qml_run:toggle()
end

--- 智能构建项目
function M.smart_build()
    -- 如果构建终端存在且未被手动关闭
    if terminals.conan_build then
        -- 只是切换显示/隐藏
        terminals.conan_build:toggle()
        return
    end

    vim.cmd("wa") -- 保存所有文件

    local cwd = vim.fn.getcwd()
    local has_conanfile = vim.fs.find("conanfile.py", { path = cwd, upward = true, type = "file" })[1] ~= nil
    local has_cmakelist = vim.fs.find("CMakeLists.txt", { path = cwd, upward = true, type = "file" })[1] ~= nil

    if has_conanfile then
        terminals.build_completed = false -- 重置构建完成标志
        terminals.conan_build = _create_terminal(
            config.build.conan_build_cmd,
            "build",
            function(term, job_id, exit_code, event)
                if exit_code == 0 then
                    vim.notify("构建成功", vim.log.levels.INFO)
                else
                    vim.notify("构建失败", vim.log.levels.ERROR)
                end
            end
        )
        terminals.conan_build:toggle()
    elseif has_cmakelist then
        vim.cmd("CMakeRun")
    else
        _create_qml_run_terminal()
    end
end

--- 运行可执行文件
-- @param executable_path string|nil 指定要运行的可执行文件路径
function M.run_executable(executable_path)
    -- 查找可执行文件
    local executable, build_type = _find_executable(executable_path)

    if not executable then
        vim.notify("没有找到可执行文件。请确认：\n1. 项目已构建\n2. 可执行文件位于标准构建目录",
            vim.log.levels.WARN)
        return
    end

    -- 关闭之前的运行终端（如果有）
    if terminals.run_term then
        terminals.run_term:shutdown()
    end

    -- 创建并显示新终端
    terminals.run_term = _create_terminal(executable, "run")

    -- 添加构建类型信息到终端标题
    if build_type ~= "" then
        terminals.run_term:change_title("Run [" .. build_type .. "]: " .. vim.fn.fnamemodify(executable, ":t"))
    else
        terminals.run_term:change_title("Run: " .. vim.fn.fnamemodify(executable, ":t"))
    end

    terminals.run_term:toggle()
end

return M
