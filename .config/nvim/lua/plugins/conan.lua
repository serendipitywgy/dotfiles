local dev_path = "/home/aoi/Music/fork-conan/nvim-conan"
if vim.fn.isdirectory(dev_path) == 1 then
    vim.api.nvim_create_user_command("Conan", function(opts)
        vim.opt.runtimepath:prepend(dev_path)
        vim.api.nvim_del_user_command("Conan")
        local ok, conan = pcall(require, "conan")
        if ok then
            conan.setup()
            vim.cmd("Conan " .. opts.args)
        else
            vim.notify("nvim-conan: " .. tostring(conan), vim.log.levels.WARN)
        end
    end, {
        nargs = "+",
        bang = true,
        desc = "Conan commands (lazy-loaded)",
    })
end
