vim.pack.add({
    { src = "https://github.com/kawre/leetcode.nvim" },
})

require("leetcode").setup({
    arg = "leetcode.nvim",
    lang = "cpp",
    cn = { -- leetcode.cn
        enabled = true, ---@type boolean
        translator = true, ---@type boolean
        translate_problems = true, ---@type boolean
    },
    ---@type lc.storage
    storage = {
        home = vim.fn.stdpath("data") .. "/leetcode",
        cache = vim.fn.stdpath("cache") .. "/leetcode",
    },
})
