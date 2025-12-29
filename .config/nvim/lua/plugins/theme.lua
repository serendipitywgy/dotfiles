vim.pack.add({
    { src = "https://github.com/catppuccin/nvim" },
})

require("catppuccin").setup()
vim.cmd("colorscheme catppuccin")
vim.cmd.hi("statusline guibg=NONE")
vim.cmd.hi("Commnet gui=NONE")
