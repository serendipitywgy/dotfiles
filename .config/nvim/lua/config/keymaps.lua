-- 定义一个函数来设置多个键映射
local function set_keymaps(mode, keymaps, target, opts)
    for _, keymap in ipairs(keymaps) do
        vim.keymap.set(mode, keymap, target, opts)
    end
end

-- -- 定义诊断提示状态变量
-- local diagnostics_enabled = true
--
-- -- 绑定快捷键（例如 <leader>dt）
-- set_keymaps("n", { "<leader>cd" }, function()
--   if diagnostics_enabled then
--     vim.diagnostic.enable(false) -- 更新：禁用诊断
--     print("Diagnostics disabled")
--   else
--     vim.diagnostic.enable(true)  -- 更新：启用诊断 (或者直接用 vim.diagnostic.enable())
--     print("Diagnostics enabled")
--   end
--   diagnostics_enabled = not diagnostics_enabled
-- end, { desc = "是否开启诊断显示" })

-- 基础导航增强,目的：在长行自动换行时可以按视觉行而不是实际行移动
set_keymaps({ "n", "x" }, { "j" }, "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
set_keymaps({ "n", "x" }, { "k" }, "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- 插入模式下，按下 kj 或 KJ 不执行任何操作
set_keymaps("i", { "kj", "KJ" }, "<Esc>", { silent = true })

-- 窗口导航
set_keymaps("n", { "<C-h>" }, "<C-w>h", { desc = "Go to Left Window", remap = true })
set_keymaps("n", { "<C-j>" }, "<C-w>j", { desc = "Go to Lower Window", remap = true })
set_keymaps("n", { "<C-k>" }, "<C-w>k", { desc = "Go to Upper Window", remap = true })
set_keymaps("n", { "<C-l>" }, "<C-w>l", { desc = "Go to Right Window", remap = true })

-- buffer的更换
set_keymaps("n", { "<S-h>" }, "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
set_keymaps("n", { "<S-l>" }, "<cmd>bnext<cr>", { desc = "Next Buffer" })
set_keymaps("n", { "<leader>bD" }, "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- lazy
-- set_keymaps("n", { "<leader>l" }, "<cmd>Lazy<cr>", { desc = "Lazy" })

--lsp formatting
-- set_keymaps({ "n" }, { "<leader>lf" }, function() vim.lsp.buf.format() end, { desc = "lsp格式化" })

set_keymaps({ "n", "v" }, { "<leader>lf" }, function()
    -- 获取当前模式
    local mode = vim.api.nvim_get_mode().mode
    if mode == "v" or mode == "V" or mode == " " then
        -- 如果是可视模式，获取选中的起始和结束位置
        local start_pos = vim.fn.getpos("v")
        local end_pos = vim.fn.getpos(".")

        vim.lsp.buf.format({
            range = {
                ["start"] = { start_pos[2], start_pos[3] - 1 },
                ["end"] = { end_pos[2], end_pos[3] - 1 },
            }
        })
        -- 格式化后跳回普通模式
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
    else
        -- 普通模式下默认格式化整个文件
        vim.lsp.buf.format({ async = true })
    end
end, { desc = "LSP格式化 (支持范围)" })
-- quit
set_keymaps("n", { "<leader>qq" }, "<cmd>wqa<cr>", { desc = "Quit All" })
set_keymaps("n", { "<leader>w" }, "<cmd>w<cr>", { desc = "保存当前Buffer", nowait = true })
set_keymaps("n", { "<leader>q" }, "<cmd>q<cr>", { desc = "退出当前Buffer", nowait = true }) -- nowait: 不延迟

-- highlights under cursor
set_keymaps("n", { "<leader>ui" }, vim.show_pos, { desc = "Inspect Pos" })
set_keymaps("n", { "<leader>uI" }, function()
    vim.treesitter.inspect_tree()
    vim.api.nvim_input("I")
end, { desc = "Inspect Tree" })

-- Terminal Mappings
set_keymaps("t", { "<C-/>" }, "<cmd>close<cr>", { desc = "Hide Terminal" })
-- set_keymaps("t", {"<c-_>"}, "<cmd>close<cr>", { desc = "which_key_ignore" })

-- windows
set_keymaps("n", { "<leader>-" }, "<C-W>s", { desc = "Split Window Below", remap = true })
set_keymaps("n", { "<leader>|" }, "<C-W>v", { desc = "Split Window Right", remap = true })
set_keymaps("n", { "<leader>wd" }, "<C-W>c", { desc = "Delete Window", remap = true })
-- Resize window using <ctrl> arrow keys
set_keymaps("n", { "<C-Up>" }, "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
set_keymaps("n", { "<C-Down>" }, "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
set_keymaps("n", { "<C-Left>" }, "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
set_keymaps("n", { "<C-Right>" }, "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
--头文件/源文件切换
set_keymaps({ "v", "n" }, { "<leader>ch" }, "<cmd>LspClangdSwitchSourceHeader<CR>", { silent = true })

--清除搜索高亮
set_keymaps("n", { "<Esc>" }, "<cmd>nohlsearch<CR>", { silent = true })

--snacks的快捷键 → 已迁移到 lua/plugins/snacks.lua

