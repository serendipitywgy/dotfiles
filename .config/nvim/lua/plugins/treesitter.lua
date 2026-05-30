require('nvim-treesitter').setup()

require('nvim-treesitter').install({
    'lua', 'vim', 'vimdoc', 'query',
    'python', 'javascript', 'typescript', 'c', 'cpp', 'cmake',
    'go', 'rust', 'java',
    'html', 'css', 'json', 'toml', 'yaml', 'bash',
    'markdown', 'markdown_inline',
})

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup("TreesitterIndent", { clear = true }),
    callback = function(ev)
        local bt = vim.bo[ev.buf].buftype
        if bt ~= '' and bt ~= 'acwrite' then return end
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})
