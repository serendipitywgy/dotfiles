-- mini.icons 需要在启动时立即加载（被 bufferline、heirline 等依赖）
require("mini.icons").setup({
    style = "glyph",
    file = {
        README = { glyph = "󰆈", hl = "MiniIconsYellow" },
        ["README.md"] = { glyph = "󰆈", hl = "MiniIconsYellow" },
    },
    filetype = {
        bash = { glyph = "󱆃", hl = "MiniIconsGreen" },
        sh = { glyph = "󱆃", hl = "MiniIconsGrey" },
        toml = { glyph = "󱄽", hl = "MiniIconsOrange" },
    },
})

-- mini.ai / mini.surround 首次进入 buffer 时才需要
vim.api.nvim_create_autocmd("BufReadPost", {
    once = true,
    callback = function()
        require("mini.ai").setup({
            mappings = {
                goto_left = "[",
                got_right = "]",
            },
        })
        require("mini.surround").setup({
            mappings = {
                add = "sa",
                delete = "sd",
                find = "sf",
                find_left = "sF",
                highlight = "sh",
                replace = "sr",
                update_n_lines = "sn",
                suffix_last = "l",
                suffix_next = "n",
            },
        })
    end,
})
