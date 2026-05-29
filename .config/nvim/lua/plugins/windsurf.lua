-- 禁用默认按键绑定
vim.g.codeium_disable_bindings = 1

-- ── Codeium 快捷键 ─────────────────────────────────────────────────────────
vim.keymap.set("i", "<C-g>", function() return vim.fn['codeium#Accept']() end,           { expr = true, silent = true })
vim.keymap.set("i", "<C-h>", function() return vim.fn['codeium#AcceptNextWord']() end,   { expr = true, silent = true })
vim.keymap.set("i", "<C-j>", function() return vim.fn['codeium#AcceptNextLine']() end,   { expr = true, silent = true })
vim.keymap.set("i", "<C-;>", function() return vim.fn['codeium#CycleCompletions'](1) end,  { expr = true, silent = true })
vim.keymap.set("i", "<C-,>", function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
vim.keymap.set("i", "<C-x>", function() return vim.fn['codeium#Clear']() end,            { expr = true, silent = true })
