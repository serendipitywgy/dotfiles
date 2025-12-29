vim.pack.add({
    { src = "https://github.com/folke/snacks.nvim" },
})
-- Picker
require("snacks").setup({
    bigfile = { enabled = true },
    zen = { enabled = true },
    -- dashboard = {
    --     sections = {
    --         { section = "header" },
    --         {
    --             pane = 2,
    --             section = "terminal",
    --             cmd = "colorscript -e square",
    --             height = 5,
    --             padding = 1,
    --         },
    --         { section = "keys",  gap = 1,    padding = 1 },
    --         { pane = 2,          icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    --         { pane = 2,          icon = " ", title = "Projects",     section = "projects",     indent = 2, padding = 1 },
    --         {
    --             pane = 2,
    --             icon = " ",
    --             title = "Git Status",
    --             section = "terminal",
    --             enabled = function()
    --                 return Snacks.git.get_root() ~= nil
    --             end,
    --             cmd = "git status --short --branch --renames",
    --             height = 5,
    --             padding = 1,
    --             ttl = 5 * 60,
    --             indent = 3,
    --         },
    --         { section = "startup" },
    --     },
    -- },
    explorer = { enabled = false, replace_netrw = true },
    indent = {
        enabled = true,
        animate = {
            enabled = false
        },
        indent = {
            only_scope = true
        },
        scope = {
            enabled = true,   -- enable highlighting the current scope
            underline = true, -- underline the start of the scope
        },
        chunk = {
            -- when enabled, scopes will be rendered as chunks, except for the top-level scope which will be rendered as a scope.
            enabled = true,
        },
    },
    input = { enabled = true },
    notifier = {
        enabled = true,
        timeout = 3000,
        style = "notification",
    },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    lazygit = {
        enabled = false,
        configure = false,
    },
    styles = {
        terminal = {
            relative = "editor",
            border = "rounded",
            position = "float",
            backdrop = 60,
            height = 0.9,
            width = 0.9,
            zindex = 50,
        }
    },
})
