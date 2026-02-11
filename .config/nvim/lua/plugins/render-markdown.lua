-- 1. 启动 Neovim 运行到 require("plugins.render-markdown") 时，
--    这一步会确保插件被下载并加入 runtimepath，但不会自动运行插件逻辑。
vim.pack.add({
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})

local M = {}

-- 2. 定义一个给 autocmd 调用的初始化函数
function M.init()
    local ok, rm = pcall(require, "render-markdown")
    if not ok then return end

    rm.setup({
        -- -- 您的配置参数
        -- render_modes = { 'n', 'c', 'i', 'v' },
        -- heading = {
        --     icons = { '   ', '   ', '   ', '   ', '   ', '   ' },
        -- },
        -- code = {
        --     style = 'full',
        --     width = 'block',
        -- },
        -- win_options = {
        --     conceallevel = { default = vim.o.conceallevel, rendered = 2 },
        -- },
    })

    -- 在 markdown 文件中，按 <leader>mc (Markdown Code) 插入代码块
    vim.keymap.set('n', '<leader>mc', function()
        local lang = vim.fn.input("Language: ")
        local lines = {
            "```" .. lang,
            "",
            "```"
        }
        vim.api.nvim_put(lines, 'l', true, true)
        -- 将光标上移一行
        vim.cmd("normal! k")
        -- 进入插入模式
        vim.cmd("startinsert")
    end, { desc = "插入 Markdown 代码块", buffer = true })
end

return M
