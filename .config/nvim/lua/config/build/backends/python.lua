local M = { name = "python" }

function M.detect(ctx)
    if ctx.filetype ~= "python" then return nil end
    return {
        root = vim.fs.root(ctx.path, { "pyproject.toml", "uv.lock", ".git" }) or ctx.directory,
    }
end

function M.run(ctx)
    local overseer = require("plugins.overseer").ensure()
    local uses_uv = vim.uv.fs_stat(ctx.root .. "/pyproject.toml") or vim.uv.fs_stat(ctx.root .. "/uv.lock")
    local task = overseer.new_task({
        name = "Run " .. vim.fs.basename(ctx.path),
        cmd = uses_uv and { "uv" } or { "python3" },
        args = uses_uv and { "run", "python", ctx.path } or { ctx.path },
        cwd = ctx.root,
        components = { "default" },
    })
    task:start()
    require("plugins.overseer").open()
end

function M.debug(ctx)
    local dap = require("plugins.debug").ensure()
    dap.run({
        name = "Debug " .. vim.fs.basename(ctx.path),
        type = "python",
        request = "launch",
        program = ctx.path,
        cwd = ctx.root,
        console = "integratedTerminal",
    })
end

return M
