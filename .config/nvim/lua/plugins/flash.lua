-- require("flash").setup({})

-- ── Flash 快捷键 ───────────────────────────────────────────────────────────
-- 用到时才 require，避免启动时加载
vim.keymap.set({ "n", "x", "o" }, "ss", function()
    if not package.loaded["flash"] then
        require("flash").setup({})
    end
    require("flash").jump()
end, { desc = "快速跳转" })
