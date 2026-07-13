-- 自动命令配置
local function augroup(name)
    return vim.api.nvim_create_augroup("my_" .. name, { clear = true })
end

-- 全文件匹配重命名（LSP 重命名由 inc-rename.lua 接管）
vim.keymap.set("n", "<leader>rf", function()
    local curr_word = vim.fn.expand("<cword>")
    vim.ui.input({ prompt = "Rename all in file: ", default = curr_word }, function(new_name)
        if new_name and #new_name > 0 then
            -- 构造替换命令，%s 表示全文件，\V 精确匹配
            local cmd = string.format("%%s/\\V%s/%s/g", curr_word, new_name)
            vim.cmd(cmd)
        end
    end)
end, { desc = "文件内重命名" })
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
                desc = "关闭缓冲区",
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
        -- 彩虹缩进线（不随主题变化）
        vim.api.nvim_set_hl(0, "SnacksIndent1", { fg = "#cba6f7" })
        vim.api.nvim_set_hl(0, "SnacksIndent2", { fg = "#89b4fa" })
        vim.api.nvim_set_hl(0, "SnacksIndent3", { fg = "#a6e3a1" })
        vim.api.nvim_set_hl(0, "SnacksIndent4", { fg = "#f9e2af" })
        vim.api.nvim_set_hl(0, "SnacksIndent5", { fg = "#fab387" })
        vim.api.nvim_set_hl(0, "SnacksIndent6", { fg = "#f38ba8" })
        vim.api.nvim_set_hl(0, "SnacksIndent7", { fg = "#94e2d5" })
        vim.api.nvim_set_hl(0, "SnacksIndent8", { fg = "#b4befe" })
    end,
})
-- -- 为cpp文件设置禁止自动格式化
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = "cpp",
--     callback = function()
--         vim.b.autoformat = false
--     end,
-- })


-- 禁止自动延续注释（回车或 o/O 换行后不自动插入注释符）
vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup("no_auto_comment"),
    callback = function()
        vim.opt_local.formatoptions:remove({ "r", "o" })
    end,
})

-- markdown的懒加载

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "codecompanion" },
    callback = function()
        -- 调用 init 运行 setup
        require("plugins.render-markdown").init()

        -- 可选：针对 0.12 强制刷新渲染
        vim.schedule(function()
            if vim.fn.exists(":RenderMarkdown") == 2 then
                vim.cmd("RenderMarkdown enable")
            end
        end)
    end,
})
