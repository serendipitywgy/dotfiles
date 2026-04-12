local P = {
    name = "yazi.nvim",
    module = "yazi",
    deps = { "plenary.nvim" },
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
end, { desc = "Open yazi" })
