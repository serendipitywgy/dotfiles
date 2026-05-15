-- 初始化 Mason
require("mason").setup()

-- 配置 mason-lspconfig：自动安装以下 LSP 服务器
-- 每次启动 nvim 会自动检查并安装未安装的服务器
require("mason-lspconfig").setup({
    ensure_installed = { "clangd", "pyright", "cmake", "bashls", "jsonls", "lua_ls", "qmlls" },
})

-- Lua LSP 配置 (lua_ls)
-- 自定义 lua_ls 的配置，因为 nvim-lspconfig 的默认配置可能不够完善
vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') }, -- Lua 运行时
            diagnostics = { globals = { 'vim' } },                                 -- 忽略全局变量 vim 的警告
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
            },
            format = { enable = true }, -- 启用格式化
        },
    },
})

-- 启用 LSP 服务器
-- vim.lsp.enable 会根据文件类型自动启动对应的 LSP
for _, server in ipairs({ "clangd", "pyright", "cmake", "bashls", "jsonls", "lua_ls", "qmlls" }) do
    -- vim.lsp.config(server, {})
    vim.lsp.enable(server, {})
end

-- 配置 LSP 诊断信息的显示样式
-- 包括虚拟文本、浮动窗口、严重程度排序和图标
local icons = require("config/icons")
vim.diagnostic.config {
    virtual_text = { current_line = true },
    float = { severity_sort = true },
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
            [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
            [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
        },
    },
}

-- LSP Attach 自动配置
-- 当 LSP 客户端附加到缓冲区时自动执行以下配置
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("SetupLSP", {}),
    callback = function(event)
        local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

        -- [Inlay Hint] 内联提示
        -- 启用/禁用代码中的类型提示（如参数类型、返回值类型）
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            vim.keymap.set('n', '<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, { buffer = event.buf, desc = 'LSP: 切换内联提示' })
        end

        -- [Folding] 代码折叠
        -- 使用 LSP 提供的信息来折叠代码（如函数、类、注释块）
        if client and client:supports_method 'textDocument/foldingRange' then
            local win = vim.fn.win_getid()
            vim.wo[win].foldexpr = 'v:lua.vim.lsp.foldexpr()'
        end

        -- [Keymaps] LSP 相关快捷键
        -- 格式化代码
        vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
-- 跳转到定义 (gd)
        -- 使用 snacks picker 显示所有定义位置
        vim.keymap.set("n", "gd", function()
            local params = vim.lsp.util.make_position_params(0, "utf-8")
            vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result, _, _)
                if not result or vim.tbl_isempty(result) then
                    vim.notify("No definition found", vim.log.levels.INFO)
                else
                    require("snacks").picker.lsp_definitions()
                end
            end)
        end, { buffer = event.buf, desc = "LSP: 跳转到定义" })

        -- 带有智能分屏的跳转到定义 (gD)
        -- 根据窗口大小自动选择横向或纵向分屏
        vim.keymap.set("n", "gD", function()
            local win = vim.api.nvim_get_current_window()
            local width = vim.api.nvim_win_get_width(win)
            local height = vim.api.nvim_win_get_height(win)

            -- Mimic tmux formula: 8 * width - 20 * height
            local value = 8 * width - 20 * height
            if value < 0 then
                vim.cmd("split")  -- vertical space is more: horizontal split
            else
                vim.cmd("vsplit") -- horizontal space is more: vertical split
            end

            vim.lsp.buf.definition()
        end, { buffer = event.buf, desc = "LSP: 跳转到定义 (分屏)" })

        -- [f] 跳转到当前函数的开始位置
        local function jump_to_current_function_start()
            local params = { textDocument = vim.lsp.util.make_text_document_params() }
            local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
            if not responses then return end

            local pos = vim.api.nvim_win_get_cursor(0)
            local line = pos[1] - 1

            local function find_symbol(symbols)
                for _, s in ipairs(symbols) do
                    local range = s.range or (s.location and s.location.range)
                    if range and line >= range.start.line and line <= range["end"].line then
                        if s.children then
                            local child = find_symbol(s.children)
                            if child then return child end
                        end
                        return s
                    end
                end
            end

            for _, resp in pairs(responses) do
                local sym = find_symbol(resp.result or {})
                if sym and sym.range then
                    vim.api.nvim_win_set_cursor(0, { sym.range.start.line + 1, 0 })
                    return
                end
            end
        end
        vim.keymap.set("n", "[f", jump_to_current_function_start, { desc = "跳转到当前函数开头" })

        -- ]f] 跳转到当前函数的结束位置
        local function jump_to_current_function_end()
            local params = { textDocument = vim.lsp.util.make_text_document_params() }
            local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
            if not responses then return end

            local pos = vim.api.nvim_win_get_cursor(0)
            local line = pos[1] - 1

            local function find_symbol(symbols)
                for _, s in ipairs(symbols) do
                    local range = s.range or (s.location and s.location.range)
                    if range and line >= range.start.line and line <= range["end"].line then
                        if s.children then
                            local child = find_symbol(s.children)
                            if child then return child end
                        end
                        return s
                    end
                end
            end

            for _, resp in pairs(responses) do
                local sym = find_symbol(resp.result or {})
                if sym and sym.range then
                    -- jump to end of the symbol
                    vim.api.nvim_win_set_cursor(0, { sym.range["end"].line + 1, 0 })
                    return
                end
            end
        end
        vim.keymap.set("n", "]f", jump_to_current_function_end, { desc = "跳转到当前函数结尾" })
    end,
})

-- vim.cmd([[set completeopt+=menuone,noselect,popup]])
