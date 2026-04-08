vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

-- nvim-treesitter main 分支（1.0 重写版）setup 只接受 install_dir 一个选项
require('nvim-treesitter').setup()

local install = require('nvim-treesitter.install')

-- 启动时安装指定列表
install.ensure_installed(
    'diff', 'snakemake',
    'lua', 'vim', 'vimdoc', 'query',                                     -- Neovim 相关
    'python', 'javascript', 'typescript', 'c', 'cpp', 'cmake',           -- 常用编程语言
    'html', 'css', 'json', 'markdown', 'markdown_inline', 'toml'         -- 标记语言
)

-- 遇到新语言自动安装
install.setup_auto_install()

-- 为所有 filetype 启用 treesitter 高亮（Neovim 0.12 原生功能）
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
    callback = function(ev)
        local disabled = { latex = true }
        if disabled[vim.bo[ev.buf].filetype] then return end
        pcall(vim.treesitter.start)
    end,
})

-- 为所有 filetype 启用 treesitter 缩进（实验性）
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup("TreesitterIndent", { clear = true }),
    callback = function(ev)
        local disabled = { ruby = true }
        if disabled[vim.bo[ev.buf].filetype] then return end
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})
