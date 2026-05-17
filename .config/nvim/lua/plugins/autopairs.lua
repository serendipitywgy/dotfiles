------------------------------------------------
-- 1. autopairs：第一次进入插入模式时初始化
------------------------------------------------
vim.api.nvim_create_autocmd("InsertEnter", {
    group = vim.api.nvim_create_augroup("SetupAutoPairs", { clear = true }),
    once   = true,
    callback = function()
        require("nvim-autopairs").setup({})   -- 这里放你自己的 opts
    end,
})

