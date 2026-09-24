local M = { name = "single-file" }

local single = require("config.build.single_file")

function M.detect(ctx)
    if ctx.filetype ~= "c" and ctx.filetype ~= "cpp" then return nil end
    return { root = ctx.directory }
end

local function build(ctx, on_success)
    local overseer = require("plugins.overseer").ensure()
    local task = overseer.new_task(assert(single.task_definition(ctx.path, ctx.filetype)))
    if on_success then
        task:subscribe("on_complete", function(_, status)
            if status == overseer.STATUS.SUCCESS then vim.schedule(on_success) end
        end)
    end
    task:start()
    require("plugins.overseer").open()
end

function M.build(ctx) build(ctx) end

function M.run(ctx)
    build(ctx, function()
        local task = require("plugins.overseer").ensure().new_task({
            name = "Run " .. vim.fs.basename(ctx.path),
            cmd = { single.executable(ctx.path) },
            cwd = ctx.directory,
            components = { "default" },
        })
        task:start()
        require("plugins.overseer").open()
    end)
end

function M.debug(ctx)
    local dap = require("plugins.debug").ensure()
    dap.run({
        name = "Debug " .. vim.fs.basename(ctx.path),
        type = "codelldb",
        request = "launch",
        program = single.executable(ctx.path),
        cwd = ctx.directory,
        stopOnEntry = false,
        preLaunchTask = "Build current C/C++ file",
    })
end

return M
