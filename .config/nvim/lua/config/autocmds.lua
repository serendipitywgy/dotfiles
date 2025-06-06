-- 自动命令配置
local function augroup(name)
    return vim.api.nvim_create_augroup("my_" .. name, { clear = true })
end

-- 在这里可以添加其他自动命令
-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})
-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        (vim.hl or vim.highlight).on_yank()
    end,
})
-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
            return
        end
        vim.b[buf].lazyvim_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})


-- 快速关闭特殊缓冲区
-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "PlenaryTestPopup",
        "checkhealth",
        "dbout",
        "gitsigns-blame",
        "grug-far",
        "help",
        "lspinfo",
        "neotest-output",
        "neotest-output-panel",
        "neotest-summary",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
            vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
            })
        end)
    end,
})


-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("man_unlisted"),
    pattern = { "man" },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
    end,
})


-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = false
    end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = augroup("json_conceal"),
    pattern = { "json", "jsonc", "json5" },
    callback = function()
        vim.opt_local.conceallevel = 0
    end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = augroup("auto_create_dir"),
    callback = function(event)
        if event.match:match("^%w%w+:[\\/][\\/]") then
            return
        end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        -- 覆盖lualine的高亮组
        vim.api.nvim_set_hl(0, "lualine_a_normal", { fg = "#f8f8f2", bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "lualine_b_normal", { fg = "#f8f8f2", bg = "NONE" })
        vim.api.nvim_set_hl(0, "lualine_c_normal", { fg = "#f8f8f2", bg = "NONE" })
        -- 可以添加更多高亮组...
    end,
})
-- 为cpp文件设置禁止自动格式化
vim.api.nvim_create_autocmd("FileType", {
    pattern = "cpp",
    callback = function()
        vim.b.autoformat = false
    end,
})

--lsp的一些自动命令

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        vim.keymap.set('n', '<leader>sd', function()
            vim.diagnostic.open_float { source = true }
        end, { buffer = event.buf, desc = 'LSP: Show Diagnostic' })

        vim.keymap.set(
            'n',
            '<leader>cd',
            (function()
                local diag_status = 1 -- 1 is show; 0 is hide
                return function()
                    if diag_status == 1 then
                        diag_status = 0
                        vim.diagnostic.config { underline = false, virtual_text = false, signs = false, update_in_insert = false }
                    else
                        diag_status = 1
                        vim.diagnostic.config { underline = true, virtual_text = true, signs = true, update_in_insert = true }
                    end
                end
            end)(),
            { buffer = event.buf, desc = 'LSP: Toggle diagnostics display' }
        )


        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method 'textDocument/foldingRange' then
            vim.o.foldmethod = 'expr'
            -- Default to treesitter folding
            vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            local win = vim.api.nvim_get_current_win()
            vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
        end

        -- Inlay hint
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            -- vim.lsp.inlay_hint.enable()
            vim.keymap.set('n', '<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, { buffer = event.buf, desc = 'LSP: Toggle Inlay Hints' })
        end

    end
})
