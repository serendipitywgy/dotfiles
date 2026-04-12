require("which-key").setup({
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
    expand = function(node)
        return not node.desc
    end,
})
