local treesitter = require('nvim-treesitter')

treesitter.install({
    'lua', 'vim', 'vimdoc', 'query',
    'python', 'javascript', 'typescript', 'c', 'cpp', 'cmake',
    'go', 'rust', 'java',
    'html', 'css', 'json', 'toml', 'yaml', 'bash', 'xml',
    'markdown', 'markdown_inline',
})

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('TreesitterFeatures', { clear = true }),
    callback = function(ev)
        local bt = vim.bo[ev.buf].buftype
        if bt ~= '' and bt ~= 'acwrite' then return end

        local ft = vim.bo[ev.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if lang and vim.treesitter.language.add(lang) then
            local ok, highlights = pcall(vim.treesitter.query.get, lang, 'highlights')
            if ok and highlights then
                vim.treesitter.start(ev.buf, lang)
            end
        end

        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})
