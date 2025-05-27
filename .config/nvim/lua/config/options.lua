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
        wrap = true,         -- 启用自动换行
        colorcolumn = "150", -- 在第150列显示垂直线，用于提示代码宽度
        cursorline = true,   -- 高亮当前行
        ignorecase = true,   -- 搜索时忽略大小写
        smartcase = true,    -- 如果搜索包含大写字母，则变为大小写敏感
        foldlevel = 99,      -- 设置折叠级别
        foldenable = false,  -- 默认不启用代码折叠
        expandtab = true,    -- 将制表符展开为空格
        softtabstop = 4,     -- 软制表符宽度为4
        shiftwidth = 4,      -- 自动缩进宽度为4
        tabstop = 4,         -- 制表符宽度为4
        cindent = true,      -- 启用C语言样式缩进
        cino = "(0,W4",      -- 设置C语言缩进选项
        splitbelow = true,   -- 新窗口在下方
        splitright = true,   -- 新窗口在右边
        undofile = true,     --启用了 Neovim 的持久化撤销历史功能


        -- 设置窗口标题为当前文件名或项目名
        title = true,
        titlestring = "%{expand('%:p:h:t')} - Neovide"
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
