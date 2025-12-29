vim.pack.add({
    { src = "https://github.com/yetone/avante.nvim" },
})

require("avante").setup({
    build = vim.fn.has("win32") ~= 0
        and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or "make",
    opts = {
        provider = "copilot",
        copilot = {
            endpoint = "https://api.githubcopilot.com",
            model = "claude-3.5-sonnet",
            proxy = nil,            -- [protocol://]host[:port] Use this proxy
            allow_insecure = false, -- Allow insecure server connections
            timeout = 30000,        -- Timeout in milliseconds
            temperature = 0,
            max_tokens = 20480,
        },
    },
})
