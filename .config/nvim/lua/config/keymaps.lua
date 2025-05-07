-- vim.keymap.set("i", "kj", "<Esc>", { silent = true })
-- vim.keymap.set("t", "kj", "<C-\\><C-n>", { silent = true })
-- 定义一个函数来设置多个键映射
local function set_keymaps(mode, keymaps, target, opts)
	for _, keymap in ipairs(keymaps) do
		vim.keymap.set(mode, keymap, target, opts)
	end
end

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

set_keymaps("n", { "<leader>bd" }, function()
	Snacks.bufdelete()
end, { desc = "Delete Buffer" })

set_keymaps("n", { "<leader>bo" }, function()
	Snacks.bufdelete.other()
end, { desc = "Delete Other Buffer" })

set_keymaps("n", { "<leader>bD" }, "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- lazy
set_keymaps("n", { "<leader>l" }, "<cmd>Lazy<cr>", { desc = "Lazy" })

-- formatting
set_keymaps({ "n", "v" }, {"<leader>cf"}, function()
	require("conform").format()
end, { desc = "Format" })

-- quit
set_keymaps("n", {"<leader>qq"}, "<cmd>wqa<cr>", { desc = "Quit All" })

-- highlights under cursor
set_keymaps("n", {"<leader>ui"}, vim.show_pos, { desc = "Inspect Pos" })
set_keymaps("n", {"<leader>uI"}, function() vim.treesitter.inspect_tree() vim.api.nvim_input("I") end, { desc = "Inspect Tree" })


-- floating terminal
set_keymaps("n", {"<leader>fT"}, function() Snacks.terminal() end, { desc = "Terminal (cwd)" })
set_keymaps("n", {"<leader>ft"}, function() Snacks.terminal(nil, { cwd = Root.get() }) end, { desc = "Terminal (Root Dir)" })
set_keymaps("n", {"<c-/>"},      function() Snacks.terminal(nil, { cwd = Root.get() }) end, { desc = "Terminal (Root Dir)" })
set_keymaps("n", {"<c-_>"},      function() Snacks.terminal(nil, { cwd = Root.get() }) end, { desc = "which_key_ignore" })

-- Terminal Mappings
set_keymaps("t", {"<C-/>"}, "<cmd>close<cr>", { desc = "Hide Terminal" })
set_keymaps("t", {"<c-_>"}, "<cmd>close<cr>", { desc = "which_key_ignore" })

-- windows
set_keymaps("n", {"<leader>-"}, "<C-W>s", { desc = "Split Window Below", remap = true })
set_keymaps("n", {"<leader>|"}, "<C-W>v", { desc = "Split Window Right", remap = true })
set_keymaps("n", {"<leader>wd"}, "<C-W>c", { desc = "Delete Window", remap = true })


-- lazygit
if vim.fn.executable("lazygit") == 1 then
  set_keymaps("n", {"<leader>gg"}, function() Snacks.lazygit( { cwd = Root.git() }) end, { desc = "Lazygit (Root Dir)" })
  set_keymaps("n", {"<leader>gG"}, function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
  set_keymaps("n", {"<leader>gf"}, function() Snacks.picker.git_log_file() end, { desc = "Git Current File History" })
  set_keymaps("n", {"<leader>gl"}, function() Snacks.picker.git_log({ cwd = Root.git() }) end, { desc = "Git Log" })
  set_keymaps("n", {"<leader>gL"}, function() Snacks.picker.git_log() end, { desc = "Git Log (cwd)" })
end

set_keymaps("n", {"<leader>gb"}, function() Snacks.picker.git_log_line() end, { desc = "Git Blame Line" })
set_keymaps({ "n", "x" }, {"<leader>gB"}, function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })
set_keymaps({"n", "x" }, {"<leader>gY"}, function()
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
end, { desc = "Git Browse (copy)" })


--头文件/源文件切换
set_keymaps({"v", "n"}, {"<leader>ch"}, "<cmd>ClangdSwitchSourceHeader<CR>", { silent = true })

--清除搜索高亮
set_keymaps("n", {"<Esc>"}, "<cmd>nohlsearch<CR>", { silent = true })
