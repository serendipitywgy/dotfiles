vim.keymap.set("n", "<leader>ws", "<cmd>AutoSession save<CR>", { desc = "保存会话" })
vim.keymap.set("n", "<leader>wr", "<cmd>AutoSession search<CR>", { desc = "搜索会话" })

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        require("auto-session").setup({
            auto_save = true,
            auto_restore = false,
            auto_create = true,
            suppressed_dirs = { "~/", "~/Downloads" },
            session_lens = {
                picker = "snacks",
                load_on_setup = true,
            },
        })
    end,
})
