vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        pcall(function()
            require("translate").setup {
                default = {
                    parse_before = "trim,natural",
                    command = "google",
                    parse_after = "window",
                    output = "floating",
                },
                preset = {
                    output = {
                        floating = {
                            border = "rounded",
                            relative = "cursor",
                            row = 1,
                            col = 1,
                        },
                    },
                },
            }
        end)
    end,
})

vim.keymap.set("n", "<leader>tw", "<Cmd>Translate zh-CN<CR>", { desc = "翻译单词/当前行" })
vim.keymap.set("v", "<leader>ts", ":'<,'>Translate zh-CN<CR>", { desc = "翻译选中文本" })
