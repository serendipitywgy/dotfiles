vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

vim.api.nvim_create_autocmd('BufReadPre', {
    group = vim.api.nvim_create_augroup("SetupTreesitter", { clear = true }),
    once = true,
    callback = function()
        ---@diagnostic disable-next-line: missing-fields
        require('nvim-treesitter.configs').setup {
            ensure_installed = {
                'diff',
                'snakemake',
                "lua", "vim", "vimdoc", "query",                                     -- Neovim 相关
                "python", "javascript", "typescript", "c", "cpp", "cmake",           -- 常用编程语言
                "html", "css", "json", "yaml", "markdown", "markdown_inline", "toml" -- 标记语言
            },
            ignore_install = {
                'latex',
                'yaml',
                'xml',
            },
            auto_install = true,
            highlight = {
                enable = true,
                disable = { 'latex' },
                additional_vim_regex_highlighting = { 'ruby' },
            },
            disable = function(lang, bufnr)
                return lang == 'yaml' and vim.api.nvim_buf_line_count(bufnr) > 5000
            end,
            indent = { enable = true, disable = { 'ruby' } },
        }
    end,
})
