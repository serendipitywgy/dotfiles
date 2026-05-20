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

-- 呼出/跳回最近一次 Conan 构建日志
vim.keymap.set("n", "<leader>bl", function()
    local utils = require("utils")
    local buf = utils.get_term_buf()
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        vim.notify("没有构建日志", vim.log.levels.WARN)
        return
    end
    for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(w) == buf then
            vim.api.nvim_set_current_win(w)
            return
        end
    end
    vim.cmd("botright sbuffer " .. buf)
end, { desc = "显示 Conan 构建日志" })
