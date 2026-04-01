vim.pack.add({
    { src = "https://github.com/rmagatti/auto-session" },
})
require("auto-session").setup({
    auto_save = true,
    auto_restore = true,
    auto_create = true,
    suppressed_dirs = { "~/", "~/Downloads" },
    session_lens = {
        picker = "snacks",
        load_on_setup = true,
    },
})
vim.keymap.set("n", "<leader>ws", "<cmd>AutoSession save<CR>", { desc = "Save session" })
vim.keymap.set("n", "<leader>wr", "<cmd>AutoSession search<CR>", { desc = "Search session" })
