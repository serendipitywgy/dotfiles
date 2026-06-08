local ok, flash = pcall(require, "flash")
if not ok then return end

flash.setup({})

vim.keymap.set({ "n", "x", "o" }, "ss", function()
  flash.jump()
end, { desc = "Flash: 快速跳转" })

vim.keymap.set({ "n", "x", "o" }, "sS", function()
  flash.treesitter()
end, { desc = "Flash: Treesitter 跳转" })

vim.keymap.set({ "n", "x", "o" }, "sR", function()
  flash.remote()
end, { desc = "Flash: 跨窗口跳转" })
