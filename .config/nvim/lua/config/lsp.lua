-- 初始化 Mason
require("mason").setup()

-- LSP 服务器统一清单(单一来源,安装/启用共用)
-- 注意:ensure_installed 只接受 lspconfig 服务器名(如 bashls/jsonls/lua_ls),
-- mason 内部会自动映射到对应的包名
local servers = {
    "clangd",
    "pyright",
    "bashls",
    "jsonls",
    "lua_ls",
    "qmlls",
    "neocmake",
}

-- 配置 mason-lspconfig：自动安装以上服务器
-- automatic_enable = false：只启用下面显式 enable 的服务器
-- (防止 mason 里装了其他服务器(如 copilot-language-server)被悄悄自动拉起 —— 之前报错的根源)
require("mason-lspconfig").setup({
    ensure_installed = servers,
    automatic_enable = false,
})

-- Lua LSP 配置 (lua_ls)
-- 自定义 lua_ls 的配置，因为 nvim-lspconfig 的默认配置可能不够完善
vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = { checkThirdParty = false },
            format = { enable = true },
        },
    },
})

-- Clangd 配置
vim.lsp.config('clangd', {
    cmd = {
        'clangd',
        '--background-index',
        '--background-index-priority=low',
        '--clang-tidy',
        '--header-insertion=never',
        '--pch-storage=memory',
        '--malloc-trim',
    },
})

-- 配置 neocmakelsp (替代 cmake-language-server，无 Python 版本问题)
vim.lsp.config('neocmake', {
    cmd = { vim.fn.stdpath('data') .. '/mason/bin/neocmakelsp', 'stdio' },
    filetypes = { 'cmake' },
    root_markers = { '.git', 'build' },
    init_options = {
        format = { enable = true },
        lint = { enable = true },
    },
})

-- 启用 LSP 服务器(vim.lsp.enable 会根据文件类型自动启动对应的 LSP)
vim.lsp.enable(servers)

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

local function configure_lsp_folds(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end

    local has_lsp_folds = next(vim.lsp.get_clients({
        bufnr = bufnr,
        method = "textDocument/foldingRange",
    })) ~= nil

    for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        vim.wo[win].foldmethod = "expr"
        vim.wo[win].foldexpr = has_lsp_folds and vim.lsp.foldexpr or vim.treesitter.foldexpr
    end
end

local lsp_group = vim.api.nvim_create_augroup("SetupLSP", { clear = true })

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = lsp_group,
    callback = function(event)
        configure_lsp_folds(event.buf)
    end,
})

vim.api.nvim_create_autocmd("LspDetach", {
    group = lsp_group,
    callback = function(event)
        vim.schedule(function()
            configure_lsp_folds(event.buf)
        end)
    end,
})

-- LSP Attach 自动配置
-- 当 LSP 客户端附加到缓冲区时自动执行以下配置
vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_group,
    callback = function(event)
        local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

        -- [Inlay Hint] 内联提示
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            vim.keymap.set('n', '<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, { buffer = event.buf, desc = 'LSP: 切换内联提示' })
        end

        -- [Diagnostics Toggle] 切换诊断显示
        vim.keymap.set('n', '<leader>cd', function()
            local filter = { bufnr = event.buf }
            vim.diagnostic.enable(not vim.diagnostic.is_enabled(filter), filter)
        end, { buf = event.buf, desc = 'LSP: 切换诊断显示' })

        vim.keymap.set('n', '<leader>xd', function()
            vim.diagnostic.open_float({ source = true, scope = 'line' })
        end, { buf = event.buf, desc = 'LSP: 当前行诊断浮窗' })

        -- [Folding] 代码折叠(0.12 内置 vim.lsp.foldexpr，基于 LSP foldingRange)
        if client:supports_method('textDocument/foldingRange', event.buf) then
            configure_lsp_folds(event.buf)
        end

        -- [Keymaps] LSP 相关快捷键
        -- 格式化代码 (keymap中已经实现)

        -- 跳转到定义 (gd)
        -- 使用 snacks picker 显示所有定义位置
        -- ⚠️ 覆盖内置 gd(C 语言:本地定义跳转;普通模式:LSP 定义)
        vim.keymap.set("n", "gd", function()
            Snacks.picker.lsp_definitions()
        end, { buf = event.buf, desc = "LSP: 跳转到定义" })

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

        -- [hover] K 悬停文档（markdown 保留 diagram 预览）
        if vim.bo[event.buf].filetype ~= "markdown" then
            vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = event.buf, desc = "LSP: 悬停文档" })
        end

        -- [code-action] LSP 代码操作
        vim.keymap.set({"n", "v"}, "<leader>ca", vim.lsp.buf.code_action, { buffer = event.buf, desc = "LSP: code action" })

        local function jump_to_current_function(use_end)
            local bufnr = event.buf
            local win = vim.api.nvim_get_current_win()
            local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
            local pos = vim.api.nvim_win_get_cursor(win)
            local line = pos[1] - 1
            local jumped = false

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

            vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", params, function(_, result)
                if jumped or not result then return end
                local sym = find_symbol(result)
                local range = sym and (sym.range or (sym.location and sym.location.range))
                if not range then return end

                jumped = true
                vim.schedule(function()
                    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
                        local target = use_end and range["end"] or range.start
                        vim.api.nvim_win_set_cursor(win, { target.line + 1, 0 })
                    end
                end)
            end)
        end

        vim.keymap.set("n", "[f", function()
            jump_to_current_function(false)
        end, { buf = event.buf, desc = "跳转到当前函数开头" })

        vim.keymap.set("n", "]f", function()
            jump_to_current_function(true)
        end, { buf = event.buf, desc = "跳转到当前函数结尾" })
    end,
})
