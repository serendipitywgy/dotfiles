local config = {
    g = {
        mapleader = " ",
        autoformat = true,
        snacks_animate = false
    },
    opt = {
        clipboard = "unnamedplus", -- 设置剪贴板选项
        spell = false,             -- 禁止使用拼写检查
        number = true,
        relativenumber = true,
        autoindent = true,
        wrap = true,           -- 启用自动换行
        colorcolumn = "150",   -- 在第150列显示垂直线，用于提示代码宽度
        cursorline = true,     -- 高亮当前行
        ignorecase = true,     -- 搜索时忽略大小写
        smartcase = true,      -- 如果搜索包含大写字母，则变为大小写敏感
        expandtab = true,      -- 将制表符展开为空格
        softtabstop = 4,       -- 软制表符宽度为4
        shiftwidth = 4,        -- 自动缩进宽度为4
        tabstop = 4,           -- 制表符宽度为4
        cindent = true,        -- 启用C语言样式缩进
        cino = "(0,W4",        -- 设置C语言缩进选项
        splitbelow = true,     -- 新窗口在下方
        splitright = true,     -- 新窗口在右边
        undofile = true,       --启用了 Neovim 的持久化撤销历史功能
        virtualedit = "block", -- 允许虚拟编辑, 允许在不可见的字符上进行操作


        -- 设置窗口标题为当前文件名或项目名
        title = true,
        titlestring = "%{expand('%:p:h:t')}"
    },
    cmd = {},
}

for scope, settings in pairs(config) do
    if scope == "g" then
        for k, v in pairs(settings) do
            vim.g[k] = v
        end
    elseif scope == "opt" then
        for k, v in pairs(settings) do
            vim.opt[k] = v
        end
    elseif scope == "cmd" then
        for _, cmd in ipairs(settings) do
            vim.cmd(cmd)
        end
    end
end

-- 配置折叠
vim.o.foldcolumn = '0' -- '0' is not bad
vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldmethod = 'expr'
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

-- Source: https://www.reddit.com/r/neovim/comments/1fzn1zt/custom_fold_text_function_with_treesitter_syntax/
local function fold_virt_text(result, start_text, lnum)
    local text = ''
    local hl
    for i = 1, #start_text do
        local char = start_text:sub(i, i)
        local captured_highlights = vim.treesitter.get_captures_at_pos(0, lnum, i - 1)
        local outmost_highlight = captured_highlights[#captured_highlights]
        if outmost_highlight then
            local new_hl = '@' .. outmost_highlight.capture
            if new_hl ~= hl then
                -- as soon as new hl appears, push substring with current hl to table
                table.insert(result, { text, hl })
                text = ''
                hl = nil
            end
            text = text .. char
            hl = new_hl
        else
            text = text .. char
        end
    end
    table.insert(result, { text, hl })
end
function _G.custom_foldtext()
    local start_text = vim.fn.getline(vim.v.foldstart):gsub('\t', string.rep(' ', vim.o.tabstop))
    local nline = vim.v.foldend - vim.v.foldstart
    local result = {}
    fold_virt_text(result, start_text, vim.v.foldstart - 1)
    -- table.insert(result, {'   ', nil }) -- spacing
    -- table.insert(result, { ' ↙ ' .. nline .. ' lines', '@comment.warning.gitcommit' })
    table.insert(result, { '  ↙' .. nline .. ' lines', '@comment.warning.gitcommit' })
    return result
end

vim.opt.foldtext = 'v:lua.custom_foldtext()'
