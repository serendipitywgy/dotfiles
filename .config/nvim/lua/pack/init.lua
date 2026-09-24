-- Keep parsers aligned with nvim-treesitter updates.
vim.api.nvim_create_autocmd("PackChanged", {
    group = vim.api.nvim_create_augroup("TreesitterParserUpdate", { clear = true }),
    callback = function(ev)
        local data = ev.data
        if not data or not data.spec or data.spec.name ~= "nvim-treesitter" then return end
        if data.kind ~= "install" and data.kind ~= "update" then return end

        if not data.active then
            vim.cmd.packadd(data.spec.name)
        end

        local config_ok, config = pcall(require, "plugins.treesitter")
        local treesitter_ok, treesitter = pcall(require, "nvim-treesitter")
        if not config_ok or not treesitter_ok then
            local err = not config_ok and config or treesitter
            vim.notify("Failed to load Treesitter after " .. data.kind .. ": " .. tostring(err), vim.log.levels.ERROR)
            return
        end

        local action = data.kind == "install" and treesitter.install or treesitter.update
        local languages = data.kind == "install" and config.parsers or nil
        local action_ok, action_err = pcall(action, languages, { summary = true })
        if not action_ok then
            vim.notify("Failed to start Treesitter parser " .. data.kind .. ": " .. tostring(action_err), vim.log.levels.ERROR)
        end
    end,
})

local lazy_plugins = {
    ["image.nvim"] = true,
    ["diagram.nvim"] = true,
    ["render-markdown.nvim"] = true,
}

-- Keep media plugins installed and locked, but leave them outside runtimepath
-- until their shared FileType loader activates them.
vim.pack.add(require("pack.plugins"), {
    load = function(plugin)
        if not lazy_plugins[plugin.spec.name] then
            vim.cmd.packadd(plugin.spec.name)
        end
    end,
})

local modules = {
    "plugins.snacks",
    "plugins.lazydev",
    "plugins.sidekick",
    "plugins.blink",
    "plugins.conform",
    "plugins.treesitter",
    "plugins.static-scroll",
    "plugins.flash",
    "plugins.noice",
    "plugins.which-key",
    "plugins.trouble",
    "plugins.oil",
    "plugins.mini",
    "plugins.autopairs",
    "plugins.bufferline",
    "plugins.heirline",
    "plugins.git",
    "plugins.auto-session",
    "plugins.overseer",
    "plugins.cmake",
    "plugins.debug",
    "plugins.render-markdown",
    "plugins.inc-rename",
    "plugins.translate",
    "plugins.windsurf",
}

for _, module in ipairs(modules) do
    require(module)
end

require("config.lsp")
