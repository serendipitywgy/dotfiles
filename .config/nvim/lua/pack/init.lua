-- Keep parsers aligned with nvim-treesitter updates.
vim.api.nvim_create_autocmd("PackChanged", {
    group = vim.api.nvim_create_augroup("TreesitterParserUpdate", { clear = true }),
    callback = function(ev)
        local data = ev.data
        if not data or not data.spec or data.spec.name ~= "nvim-treesitter" then return end
        if data.kind ~= "install" and data.kind ~= "update" then return end

        local ok, treesitter = pcall(require, "nvim-treesitter")
        if not ok then
            vim.notify("Failed to update Treesitter parsers: " .. tostring(treesitter), vim.log.levels.ERROR)
            return
        end

        local update_ok, update_err = pcall(treesitter.update, nil, { summary = true })
        if not update_ok then
            vim.notify("Failed to start Treesitter parser update: " .. tostring(update_err), vim.log.levels.ERROR)
        end
    end,
})

-- Activate every declared plugin before loading its configuration. This also
-- sources Vimscript plugin entry points such as Windsurf and tmux-navigator.
vim.pack.add(require("pack.plugins"), { load = true })

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
    "plugins.yazi",
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
    "plugins.diagram",
    "plugins.inc-rename",
    "plugins.translate",
    "plugins.windsurf",
    "plugins.ime",
}

for _, module in ipairs(modules) do
    require(module)
end

require("config.lsp")
