return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "helix",
        win = {
            title = false,
            width = 0.5,
        },
        icons = {
            separator = "│",
        },
        spec = {
            { "<leader>s", group = "<Snacks>" },
            { "<leader>t", group = "<Snacks> Toggle" },
        },
        -- expand = function(node)
        --     return not node.desc
        -- end,
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
}
