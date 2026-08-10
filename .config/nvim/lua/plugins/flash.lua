local ok, flash = pcall(require, "flash")
if not ok then return end

flash.setup({})
-- ⚠️ 注意:flash 默认开启 char 模式,会接管内置的 f/F/t/T 字符查找
-- (增强版:高亮所有匹配字符 + 标签跳转)。
-- 如需还原原生查找:flash.setup({ modes = { char = { enabled = false } } })

vim.keymap.set({ "n", "x", "o" }, "ss", function()
  flash.jump()
end, { desc = "Flash: 快速跳转" })

vim.keymap.set({ "n", "x", "o" }, "sS", function()
  flash.treesitter()
end, { desc = "Flash: Treesitter 跳转" })

vim.keymap.set({ "n", "x", "o" }, "sR", function()
  flash.remote()
end, { desc = "Flash: 跨窗口跳转" })
