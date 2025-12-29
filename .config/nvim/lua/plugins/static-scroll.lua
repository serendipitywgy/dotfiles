vim.pack.add({
    {
        src = 'https://github.com/nvim-treesitter/nvim-treesitter-context',
        name = 'nvim-treesitter-context',
    },
})

-- 加载并配置 nvim-treesitter-context（推荐全局加载，随时可用）
vim.cmd.packadd('nvim-treesitter-context')
require("treesitter-context").setup({
    enable = true,
    multiwindow = true,
    max_lines = 0,
    min_window_height = 0,
    line_numbers = true,
    multiline_threshold = 20,
    trim_scope = "outer",
    mode = "cursor",
    separator = nil,
    zindex = 20,
    on_attach = nil,
})

vim.keymap.set("n", "[c", function()
    require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })
