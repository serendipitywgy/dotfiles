local yazi = require("yazi")
yazi.setup({
    open_for_directories = false,
    keymaps = { show_help = "<f1>" },
})

vim.keymap.set({ "n", "v" }, "tt", function()
    vim.schedule(function()
        vim.api.nvim_exec_autocmds("BufReadPost", { modeline = false })
    end)
    vim.cmd("Yazi")
end, { desc = "打开 yazi" })
