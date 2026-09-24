local M = {}

local backends = {
    require("config.build.backends.cmake"),
    require("config.build.backends.python"),
    require("config.build.backends.single_file"),
}

local action_tags = {
    build = "BUILD",
    run = "RUN",
}

local function context()
    local buf = vim.api.nvim_get_current_buf()
    local path = vim.api.nvim_buf_get_name(buf)
    if path == "" then
        vim.notify("未命名 buffer 无法执行构建任务", vim.log.levels.WARN)
        return nil
    end

    if vim.bo[buf].modified then
        local ok, err = pcall(vim.cmd.update)
        if not ok then
            vim.notify("保存当前文件失败: " .. tostring(err), vim.log.levels.ERROR)
            return nil
        end
    end

    return {
        buf = buf,
        path = vim.fs.normalize(path),
        filetype = vim.bo[buf].filetype,
        directory = vim.fs.dirname(path),
    }
end

local function find_backend(ctx)
    for _, backend in ipairs(backends) do
        local result = backend.detect(ctx)
        if result then
            ctx.root = result.root or result
            ctx.conan_root = result.conan_root
            return backend
        end
    end
end

local function fallback(action)
    if action == "debug" then
        require("plugins.debug").ensure().continue()
        return
    end

    local tag = action_tags[action]
    if not tag then
        vim.notify("当前项目不支持此操作", vim.log.levels.WARN)
        return
    end

    local overseer = require("plugins.overseer").ensure()
    overseer.run_task({ tags = { overseer.TAG[tag] }, autostart = false }, function(task)
        if task then
            task:start()
            require("plugins.overseer").open()
        else
            vim.notify("没有找到可用的 " .. action .. " 任务", vim.log.levels.WARN)
        end
    end)
end

local function dispatch(action)
    local ctx = context()
    if not ctx then return end

    local backend = find_backend(ctx)
    if not backend then
        fallback(action)
        return
    end

    local handler = backend[action]
    if not handler then
        if backend.name == "python" and action == "build" then
            vim.notify("Python 无需构建，请使用 Run 或 Debug", vim.log.levels.INFO)
        else
            vim.notify(backend.name .. " 后端不支持 " .. action, vim.log.levels.WARN)
        end
        return
    end
    handler(ctx)
end

function M.build() dispatch("build") end
function M.run() dispatch("run") end
function M.debug() dispatch("debug") end
function M.configure() dispatch("configure") end
function M.select_build_type() dispatch("select") end
function M.open_output() require("plugins.overseer").open() end

vim.keymap.set("n", "<leader>cb", M.build, { desc = "构建" })
vim.keymap.set("n", "<leader>ct", M.select_build_type, { desc = "选择构建类型" })
vim.keymap.set("n", "<leader>cg", M.configure, { desc = "配置" })
vim.keymap.set("n", "<leader>co", M.open_output, { desc = "打开任务面板" })
vim.keymap.set("n", "<leader>cr", M.run, { desc = "构建并运行" })
vim.keymap.set("n", "<leader>cD", M.debug, { desc = "构建并调试" })

return M
