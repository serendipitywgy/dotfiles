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

-- ── Which-key 快捷键 ───────────────────────────────────────────────────────
-- 查看当前 buffer 的本地快捷键
vim.keymap.set({ "n", "x", "o" }, "S", function()
    require("which-key").show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })
