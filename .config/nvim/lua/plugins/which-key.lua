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
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "cmake" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>l", group = "lsp" },
        { "<leader>s", group = "search" },
        { "<leader>t", group = "toggle" },
        { "<leader>a", group = "AI/Sidekick" },
        { "<leader>u", group = "ui" },
        { "<leader>x", group = "diagnostics" },
    },
    expand = function(node)
        return not node.desc
    end,
})

-- ── Which-key 快捷键 ───────────────────────────────────────────────────────
-- 查看当前 buffer 的本地快捷键
vim.keymap.set({ "n", "x", "o" }, "S", function()
    require("which-key").show({ global = false })
end, { desc = "缓冲区本地快捷键" })
