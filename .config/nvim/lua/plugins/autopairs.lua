------------------------------------------------
-- 1. 拉取插件（与 blink 同一层级即可）
------------------------------------------------
vim.pack.add({
    { src = "https://github.com/windwp/nvim-autopairs" },
    { src = "https://github.com/kylechui/nvim-surround" },
})

------------------------------------------------
-- 2. autopairs：第一次进入插入模式时初始化
------------------------------------------------
vim.api.nvim_create_autocmd("InsertEnter", {
    group = vim.api.nvim_create_augroup("SetupAutoPairs", { clear = true }),
    once   = true,
    callback = function()
        require("nvim-autopairs").setup({})   -- 这里放你自己的 opts
    end,
})

------------------------------------------------
-- 3. surround：第一次真正需要时（VeryLazy）初始化
------------------------------------------------
vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "VeryLazy",
    group = vim.api.nvim_create_augroup("SetupSurround", { clear = true }),
    once   = true,
    callback = function()
        require("nvim-surround").setup({})   -- 这里放你自己的 opts
    end,
})
