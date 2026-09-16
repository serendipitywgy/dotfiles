-- mini.ai / mini.surround 首次进入 buffer 时才需要
vim.api.nvim_create_autocmd("BufReadPost", {
    once = true,
    callback = function()
        require("mini.ai").setup({
            mappings = {
                goto_left = "[",
                got_right = "]",
            },
        })
        require("mini.surround").setup({
            mappings = {
                add = "sa",
                delete = "sd",
                find = "sf",
                find_left = "sF",
                highlight = "sh",
                replace = "sr",
                update_n_lines = "sn",
                suffix_last = "l",
                suffix_next = "n",
            },
        })
    end,
})
