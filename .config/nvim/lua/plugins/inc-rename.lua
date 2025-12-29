vim.pack.add({
    { src = "https://github.com/smjonas/inc-rename.nvim" },
})

vim.api.nvim_create_autocmd("LspAttach", {
    once = true, -- 第一次触发后即可，不必重复 load
    callback = function()
        require("inc_rename").setup({
            input_buffer_type = "dressing",
        })
        vim.keymap.set("n", "<leader>yn", function()
            return ":IncRename " .. vim.fn.expand("<cword>")
        end, { expr = true })
    end,
})
