return {
    "nvim-treesitter/nvim-treesitter",
    main = "nvim-treesitter.configs",
    event = "VeryLazy",
    opts = {
    ensure_installed = {
            "lua", "vim", "vimdoc", "query",  -- Neovim 相关
            "python", "javascript", "typescript", "c", "cpp", "cmake",  -- 常用编程语言
            "html", "css", "json", "yaml", "markdown", "markdown_inline", "toml"  -- 标记语言
        },
        -- 自动安装上面没有列出但打开了的文件类型的解析器
        auto_install = true,
        highlight = { enable = true }
    },
}
