local P = {
    name = "yazi.nvim",
    module = "yazi",
}

vim.keymap.set({ "n", "v" }, "tt", function()
    PackUtils.load(P, function(plugin)
        plugin.setup({
            open_for_directories = false,
            keymaps = { show_help = "<f1>" },
        })
    end)
    vim.schedule(function()
        vim.api.nvim_exec_autocmds("BufReadPost", { modeline = false })
    end)
    vim.cmd("Yazi")
end, { desc = "打开 yazi" })
