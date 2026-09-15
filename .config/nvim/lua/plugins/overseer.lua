vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        require("overseer").setup({
            task_list = {
                direction = "bottom",
                min_height = 12,
                max_height = 20,
                default_detail = 1,
                keymaps = {
                    --设为 false 即可删除 overseer 的局部绑定，让 vim-tmux-navigator 接管这两个键。
                    ["<C-k>"] = false,
                    ["<C-j>"] = false,
                },
            },
        })
    end,
})

vim.keymap.set("n", "<leader>oo", "<cmd>OverseerToggle<cr>", { desc = "Toggle Overseer panel" })
vim.keymap.set("n", "<leader>or", "<cmd>OverseerRunLast<cr>", { desc = "重跑上次构建任务" })
