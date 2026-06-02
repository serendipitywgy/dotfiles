---@type overseer.ComponentFileDefinition
return {
    desc = "Run a callback when the task completes, optionally auto-dispose on SUCCESS",
    params = {
        callback = {
            desc = "Called with exit code (0=success) on completion",
            type = "opaque",
            optional = true,
        },
        dispose_on_success = {
            desc = "Auto-dispose task on SUCCESS (consistent with CMake)",
            type = "boolean",
            optional = true,
            default = false,
        },
    },
    constructor = function(params)
        return {
            on_complete = function(_, task, status, _)
                if params.callback then
                    vim.schedule(function()
                        local code = status == "SUCCESS" and 0 or 1
                        pcall(params.callback, code)
                    end)
                end
                if params.dispose_on_success and status == "SUCCESS" then
                    vim.schedule(function()
                        pcall(task.dispose, task, true)
                    end)
                end
            end,
        }
    end,
}
