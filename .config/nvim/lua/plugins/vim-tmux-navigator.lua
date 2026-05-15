if vim.env.TMUX ~= nil and vim.env.TMUX ~= "" then
    vim.keymap.set("n", "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>")
    vim.keymap.set("n", "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>")
    vim.keymap.set("n", "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>")
    vim.keymap.set("n", "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>")
else
    vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "切换到左侧窗口" })
    vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "切换到下方窗口" })
    vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "切换到上方窗口" })
    vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "切换到右侧窗口" })
end
