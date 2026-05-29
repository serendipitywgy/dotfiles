vim.api.nvim_create_autocmd("LspAttach", {
    once = true, -- 第一次触发后即可，不必重复 load
    callback = function()
        require("inc_rename").setup({
            input_buffer_type = "dressing",
        })
        vim.keymap.set("n", "<leader>rn", function()
            return ":IncRename " .. vim.fn.expand("<cword>")
        end, { expr = true, desc = "LSP 重命名" })
    end,
})
