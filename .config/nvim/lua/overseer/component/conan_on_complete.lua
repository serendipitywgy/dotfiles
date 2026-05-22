---@type overseer.ComponentFileDefinition
return {
    desc = "Run a callback when the task completes",
    params = {
        callback = {
            desc = "Called with exit code (0=success) on completion",
            type = "opaque",
            optional = true,
        },
    },
    constructor = function(params)
        return {
            on_complete = function(_, _, status, _)
                if params.callback then
                    vim.schedule(function()
                        local code = status == "SUCCESS" and 0 or 1
                        pcall(params.callback, code)
                    end)
                end
            end,
        }
    end,
}
