-- 定义一个函数来设置多个键映射
local function set_keymaps(mode, keymaps, target, opts)
    for _, keymap in ipairs(keymaps) do
        vim.keymap.set(mode, keymap, target, opts)
    end
end

-- 基础导航增强,目的：在长行自动换行时可以按视觉行而不是实际行移动
set_keymaps({ "n", "x" }, { "j" }, "v:count == 0 ? 'gj' : 'j'", { desc = "向下", expr = true, silent = true })
set_keymaps({ "n", "x" }, { "k" }, "v:count == 0 ? 'gk' : 'k'", { desc = "向上", expr = true, silent = true })

-- 移动行
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "下移行", silent = true })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "上移行", silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "下移选区", silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "上移选区", silent = true })

-- 插入模式下，按下 kj 或 KJ 不执行任何操作
set_keymaps("i", { "kj", "KJ" }, "<Esc>", { silent = true })


-- buffer的更换
set_keymaps("n", { "<S-h>" }, "<cmd>bprevious<cr>", { desc = "上一个缓冲区" })
set_keymaps("n", { "<S-l>" }, "<cmd>bnext<cr>", { desc = "下一个缓冲区" })
set_keymaps("n", { "<leader>bD" }, "<cmd>:bd<cr>", { desc = "删除缓冲区和窗口" })


-- conform 格式化

vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
        }
    end
    require("conform").format({ range = range })
end, { range = true })

set_keymaps("n", { "<leader>cf" }, "<cmd>Format<cr>", { desc = "格式化" })
set_keymaps("v", { "<leader>cf" }, ":Format<cr>", { desc = "格式化 (范围)" })
-- quit
set_keymaps("n", { "<leader>qq" }, "<cmd>wqa<cr>", { desc = "全部退出" })
set_keymaps("n", { "<leader>w" }, "<cmd>w<cr>", { desc = "保存当前Buffer" })
set_keymaps("n", { "<leader>q" }, "<cmd>q<cr>", { desc = "退出当前Buffer" })

-- highlights under cursor
set_keymaps("n", { "<leader>ui" }, vim.show_pos, { desc = "检查位置" })
set_keymaps("n", { "<leader>uI" }, function()
    vim.treesitter.inspect_tree()
    vim.api.nvim_input("I")
end, { desc = "检查语法树" })

-- Terminal Mappings（由 snacks.lua 处理 toggle）

-- windows
set_keymaps("n", { "<leader>-" }, "<C-W>s", { desc = "向下拆分窗口", remap = true })
set_keymaps("n", { "<leader>|" }, "<C-W>v", { desc = "向右拆分窗口", remap = true })
set_keymaps("n", { "<leader>wd" }, "<C-W>c", { desc = "删除窗口", remap = true })
-- Resize window using <ctrl> arrow keys
set_keymaps("n", { "<C-Up>" }, "<cmd>resize +2<cr>", { desc = "增加窗口高度" })
set_keymaps("n", { "<C-Down>" }, "<cmd>resize -2<cr>", { desc = "减少窗口高度" })
set_keymaps("n", { "<C-Left>" }, "<cmd>vertical resize -2<cr>", { desc = "减少窗口宽度" })
set_keymaps("n", { "<C-Right>" }, "<cmd>vertical resize +2<cr>", { desc = "增加窗口宽度" })
--头文件/源文件切换
set_keymaps({ "v", "n" }, { "<leader>ch" }, "<cmd>LspClangdSwitchSourceHeader<CR>", { silent = true })

-- C++ 构建
set_keymaps("n", { "<leader>cB" }, "<cmd>Conan build<CR>", { desc = "Conan build", silent = true })

--清除搜索高亮
set_keymaps("n", { "<Esc>" }, "<cmd>nohlsearch<CR>", { silent = true })

--snacks的快捷键 → 已迁移到 lua/plugins/snacks.lua
