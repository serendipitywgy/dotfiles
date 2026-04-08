vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

-- nvim-treesitter 1.0: setup 只接受 install_dir 一个选项
require('nvim-treesitter').setup()

-- 启动时安装指定列表
require('nvim-treesitter').install({
    'diff', 'snakemake',
    'lua', 'vim', 'vimdoc', 'query',
    'python', 'javascript', 'typescript', 'c', 'cpp', 'cmake',
    'html', 'css', 'json', 'markdown', 'markdown_inline', 'toml'
})

-- 打开文件时自动安装缺失的 parser
local function ts_auto_install()
    local buf = vim.api.nvim_get_current_buf()
    local filetype = vim.bo[buf].filetype
    if filetype == '' or filetype == 'qf' then return end
    
    local has_parser = pcall(vim.treesitter.language.get_lang, filetype)
    if not has_parser then
        vim.cmd('TSInstall ' .. filetype)
    end
end
vim.api.nvim_create_autocmd({ 'BufReadPost', 'FileType' }, { callback = ts_auto_install })

local enabled_ft = {
    lua = true, python = true, javascript = true, typescript = true,
    c = true, cpp = true, go = true, rust = true, java = true,
    html = true, css = true, json = true, toml = true, yaml = true,
    bash = true, sh = true, markdown = true, markdown_inline = true,
    vimdoc = true, query = true, diff = true, sql = true,
}

local function is_special_buf()
    local buftype = vim.bo.buftype
    if buftype ~= '' and buftype ~= 'acwrite' then return true end
    if vim.tbl_contains({ 'qf', 'terminal', 'help', 'vim', 'netrw' }, vim.bo.filetype) then
        return true
    end
    return false
end

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
    callback = function(ev)
        if is_special_buf() then return end
        if not enabled_ft[vim.bo[ev.buf].filetype] then return end
        pcall(vim.treesitter.start)
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup("TreesitterIndent", { clear = true }),
    callback = function(ev)
        if is_special_buf() then return end
        if not enabled_ft[vim.bo[ev.buf].filetype] then return end
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})
