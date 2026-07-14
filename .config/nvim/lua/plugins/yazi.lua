-- 接管目录打开（替代 netrw；与终端 Yazi 共用 ~/.config/yazi）
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local P = {
    name = "yazi.nvim",
    module = "yazi",
}

local function setup_yazi()
    PackUtils.load(P, function(plugin)
        plugin.setup({
            open_for_directories = true,
            keymaps = { show_help = "<f1>" },
        })
    end)
end

-- 启动时 setup，才能劫持 `nvim <dir>` / 进入目录 buffer
setup_yazi()

vim.keymap.set({ "n", "v" }, "tt", function()
    setup_yazi()
    vim.cmd("Yazi")
end, { desc = "打开 yazi" })

vim.keymap.set("n", "-", "<cmd>Yazi<cr>", { desc = "打开 yazi" })
