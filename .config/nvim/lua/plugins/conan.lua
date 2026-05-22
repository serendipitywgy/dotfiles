vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        local dev_path = "/home/aoi/Music/nvim-conan"
        if vim.fn.isdirectory(dev_path) == 1 then
            vim.opt.runtimepath:prepend(dev_path)
            local ok, conan = pcall(require, "conan")
            if ok then
                conan.setup()
            else
                vim.notify("nvim-conan: " .. tostring(conan), vim.log.levels.WARN)
            end
        end
    end,
})
