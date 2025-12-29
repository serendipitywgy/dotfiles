vim.pack.add({
    { src = "https://github.com/Exafunction/windsurf.vim" },
})


-- require("Codeium").setup({})

-- 禁用默认按键绑定
vim.g.codeium_disable_bindings = 1

-- 自定义按键绑定（可根据个人习惯修改）
-- vim.keymap.set('i', '<C-g>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
-- vim.keymap.set('i', '<C-h>', function() return vim.fn['codeium#AcceptNextWord']() end, { expr = true, silent = true })
-- vim.keymap.set('i', '<C-j>', function() return vim.fn['codeium#AcceptNextLine']() end, { expr = true, silent = true })
-- vim.keymap.set('i', '<C-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
-- vim.keymap.set('i', '<C-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
-- vim.keymap.set('i', '<C-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })

-- -- 只在指定文件类型启用 windsuf（如 Rust 和 TypeScript）
-- vim.g.codeium_filetypes_disabled_by_default = true
-- vim.g.codeium_filetypes = { rust = true, typescript = true }
